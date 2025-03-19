# 【Dify】Detailed Guide to Web Service Startup Process 🚀

> This article provides a detailed analysis of the startup mechanism, frontend application architecture, and page rendering process of the Web service in the Dify platform, helping users gain a deep understanding of how the platform's frontend service works.

## Table of Contents 📑

- [Role of Web Service in Dify](#role-of-web-service-in-dify)
- [Docker-Compose Configuration Analysis](#docker-compose-configuration-analysis)
- [Image Building and Content](#image-building-and-content)
- [Startup Process](#startup-process)
- [Environment Variables and Configuration](#environment-variables-and-configuration)
- [Frontend Application Architecture](#frontend-application-architecture)
- [Interaction with API Service](#interaction-with-api-service)
- [Monitoring and Health Checks](#monitoring-and-health-checks)
- [Extensions and Customization](#extensions-and-customization)
- [Common Issues and Solutions](#common-issues-and-solutions)

## Role of Web Service in Dify 🔄

In the Dify architecture, the Web service is responsible for providing the platform's user interface, serving as the primary interface for user interaction. Its core responsibilities include:

1. **User Interface Presentation**: Providing an intuitive console interface for managing applications, datasets, and other resources
2. **RESTful API Calls**: Sending requests to the backend API service through the browser
3. **State Management**: Maintaining application state on the frontend for a smooth user experience
4. **Responsive Design**: Supporting various devices and screen sizes
5. **Internationalization Support**: Providing a multilingual user interface
6. **Immediate Interaction Feedback**: Offering real-time feedback and notifications for user actions

The Web service is developed based on the Next.js framework, adopting a modern frontend technology stack to ensure high performance and good user experience.

## Docker-Compose Configuration Analysis 🔍

```yaml
# Frontend Web application
web:
  image: langgenius/dify-web:0.15.3
  restart: always
  environment:
    # The base URL of console application api server, refers to the Console base URL of WEB service if console domain is
    # different from api or web app domain.
    # example: http://cloud.dify.ai
    CONSOLE_API_URL: ${CONSOLE_API_URL:-}
    # The URL for Web APP api server, refers to the Web App base URL of WEB service if web app domain is different from
    # console or api domain.
    # example: http://udify.app
    APP_API_URL: ${APP_API_URL:-}
    # The DSN for Sentry error reporting. If not set, Sentry error reporting will be disabled.
    SENTRY_DSN: ${WEB_SENTRY_DSN:-}
    # Disable Next.js telemetry collection
    NEXT_TELEMETRY_DISABLED: ${NEXT_TELEMETRY_DISABLED:-0}
    # Text generation timeout in milliseconds
    TEXT_GENERATION_TIMEOUT_MS: ${TEXT_GENERATION_TIMEOUT_MS:-60000}
    # Content Security Policy whitelist
    CSP_WHITELIST: ${CSP_WHITELIST:-}
    # TOP_K maximum value setting
    TOP_K_MAX_VALUE: ${TOP_K_MAX_VALUE:-}
    # Maximum segmentation token length for indexing
    INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH: ${INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH:-}
```

### Key Configuration Points Analysis:

1. **Image Version**: Uses the `langgenius/dify-web:0.15.3` image
2. **Automatic Restart**: `restart: always` ensures automatic recovery when the service crashes
3. **Environment Variables**: Configure API endpoints, performance parameters, and monitoring settings
4. **No Service Dependencies**: Unlike API and Worker services, the Web service does not directly depend on other container services
5. **No Data Storage**: Does not require mounting persistent storage

## Image Building and Content 📦

The Web service is built on Node.js, using multi-stage builds to optimize image size:

### 1. Base Image Structure

```Dockerfile
# Base image
FROM node:20-alpine3.20 AS base
LABEL maintainer="takatost@gmail.com"

# Install timezone data package
RUN apk add --no-cache tzdata

# Dependencies installation stage
FROM base AS packages
WORKDIR /app/web
COPY package.json .
COPY yarn.lock .
RUN yarn install --frozen-lockfile

# Resource building stage
FROM base AS builder
WORKDIR /app/web
COPY --from=packages /app/web/ .
COPY . .
RUN yarn build

# Production stage
FROM base AS production
ENV NODE_ENV=production
ENV EDITION=SELF_HOSTED
ENV DEPLOY_ENV=PRODUCTION
ENV CONSOLE_API_URL=http://127.0.0.1:5001
ENV APP_API_URL=http://127.0.0.1:5001
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1

# Set timezone
ENV TZ=UTC
RUN ln -s /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

WORKDIR /app/web
COPY --from=builder /app/web/public ./public
COPY --from=builder /app/web/.next/standalone ./
COPY --from=builder /app/web/.next/static ./.next/static

COPY docker/pm2.json ./pm2.json
COPY docker/entrypoint.sh ./entrypoint.sh

# Global runtime packages
RUN yarn global add pm2 \
    && yarn cache clean \
    && mkdir /.pm2 \
    && chown -R 1001:0 /.pm2 /app/web \
    && chmod -R g=u /.pm2 /app/web

USER 1001
EXPOSE 3000
ENTRYPOINT ["/bin/sh", "./entrypoint.sh"]
```

### 2. Main Components and Dependencies

- **Next.js**: React framework for building server-rendered and static websites
- **React**: User interface library
- **TypeScript**: Type-safe JavaScript superset
- **Tailwind CSS**: Utility-first CSS framework
- **PM2**: Node.js application process manager for production
- **i18next**: Internationalization framework supporting multiple languages
- **SWR**: React Hooks library for data fetching
- **Axios**: Promise-based HTTP client

## Startup Process 🚀

The Web service startup process involves several key steps, from container initialization to application startup:

### 1. Container Initialization

When Docker starts the Web container, the entry point script (entrypoint.sh) is executed:

```bash
#!/bin/bash
set -e

# Set environment variables
export NEXT_PUBLIC_DEPLOY_ENV=${DEPLOY_ENV}
export NEXT_PUBLIC_EDITION=${EDITION}
export NEXT_PUBLIC_API_PREFIX=${CONSOLE_API_URL}/console/api
export NEXT_PUBLIC_PUBLIC_API_PREFIX=${APP_API_URL}/api

export NEXT_PUBLIC_SENTRY_DSN=${SENTRY_DSN}
export NEXT_PUBLIC_SITE_ABOUT=${SITE_ABOUT}
export NEXT_TELEMETRY_DISABLED=${NEXT_TELEMETRY_DISABLED}

export NEXT_PUBLIC_TEXT_GENERATION_TIMEOUT_MS=${TEXT_GENERATION_TIMEOUT_MS}
export NEXT_PUBLIC_CSP_WHITELIST=${CSP_WHITELIST}
export NEXT_PUBLIC_TOP_K_MAX_VALUE=${TOP_K_MAX_VALUE}
export NEXT_PUBLIC_INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH=${INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH}

# Start PM2 process manager
pm2 start ./pm2.json --no-daemon
```

This script is responsible for mapping Docker environment variables to environment variables needed by the Next.js frontend application, and using PM2 to start the Next.js service.

### 2. PM2 Configuration Analysis

The PM2 configuration file (`pm2.json`) defines how the application runs:

```json
{
  "apps": [
    {
      "name": "dify-web",
      "script": "/app/web/server.js",
      "cwd": "/app/web",
      "exec_mode": "cluster",
      "instances": 2
    }
  ]
}
```

Key parameter analysis:
- **name**: Service name, used for PM2 management
- **script**: Main script to execute, here it's the server file generated by Next.js
- **cwd**: Working directory
- **exec_mode**: Execution mode, using "cluster" mode here to leverage multi-core CPUs
- **instances**: Number of application instances created, here it's 2 instances to improve availability and performance

### 3. Next.js Server Startup

PM2 starts `server.js`, which is an optimized server file generated by the Next.js build:

1. The server initializes and loads all pre-rendered pages and resources
2. Sets up route handlers and middleware
3. Listens on the configured port (default is 3000)
4. Prepares to receive and process HTTP requests

Since Next.js uses the output mode `standalone` (configured in `next.config.js`), the build process generates a standalone server, containing all necessary dependencies, enabling it to run efficiently in a production environment.

## Environment Variables and Configuration ⚙️

The Web service uses various environment variables to configure its behavior and features:

### 1. Deployment-related Configuration

```properties
# Deployment environment: DEVELOPMENT or PRODUCTION
DEPLOY_ENV=PRODUCTION
# Edition: SELF_HOSTED or CLOUD
EDITION=SELF_HOSTED
# Console API service address
CONSOLE_API_URL=http://api:5001
# Application API service address
APP_API_URL=http://api:5001
```

### 2. Functionality and Performance Configuration

```properties
# Text generation timeout in milliseconds
TEXT_GENERATION_TIMEOUT_MS=60000
# Content Security Policy whitelist
CSP_WHITELIST=
# TOP_K maximum value setting
TOP_K_MAX_VALUE=
# Maximum segmentation token length for indexing
INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH=
```

### 3. Privacy and Monitoring Configuration

```properties
# Disable Next.js telemetry data collection
NEXT_TELEMETRY_DISABLED=1
# Sentry DSN for error monitoring
SENTRY_DSN=
# Optional site about information
SITE_ABOUT=
```

## Frontend Application Architecture 🏗️

The Dify Web service adopts a modern frontend architecture that is clear and easy to extend:

### 1. Directory Structure

```
web/
├── app/                 # Next.js application source code
│   ├── components/      # Reusable components
│   ├── contexts/        # React contexts
│   ├── hooks/           # Custom React Hooks
│   ├── i18n/            # Internationalization resources
│   ├── models/          # Data models
│   ├── pages/           # Page components
│   └── services/        # API service calls
├── public/              # Static resources
├── styles/              # Global styles
├── next.config.js       # Next.js configuration
├── package.json         # Project dependencies
└── tsconfig.json        # TypeScript configuration
```

### 2. Core Technology Overview

- **Base Framework**: Next.js as the core framework, providing routing, SSR, and static generation features
- **State Management**: React Context API and SWR for state management and data fetching
- **Styling Solution**: Tailwind CSS with CSS Modules
- **Responsive Design**: Tailwind's breakpoint system for adapting to different devices
- **Internationalization**: Using i18next to support multiple languages
- **API Interaction**: Axios as the HTTP client for backend communication

### 3. Page Rendering Process

1. **Server-side Rendering Preparation**:
   - Determine data to render based on request parameters and user status
   - Fetch necessary initial data from API

2. **Component Tree Rendering**:
   - Match appropriate page components based on the route
   - Load and inject required data
   - Render complete HTML

3. **Client-side Activation**:
   - Browser receives complete HTML and displays immediately
   - Next.js JavaScript code loads and "activates" the page
   - React takes over page interaction functionality

4. **Data Updates and Re-rendering**:
   - User interaction triggers client-side state updates
   - API requests are made as needed
   - React efficiently updates the DOM

## Interaction with API Service 🔌

Communication between the Web service and API service is a key part of the Dify platform's functionality:

### 1. Request Flow

```typescript
// Client API request example
import { fetchApps, createApp } from '@/services/apps'

// Get application list
const { data: apps, isLoading, error } = useSWR(
  'apps',
  () => fetchApps(),
  { revalidateOnFocus: false }
)

// Create new application
const handleCreateApp = async (appData) => {
  try {
    const newApp = await createApp(appData)
    mutate('apps') // Refresh application list
    return newApp
  } catch (error) {
    console.error('Failed to create app:', error)
    throw error
  }
}
```

### 2. Request Interception and Response Handling

The frontend service uses interceptors to handle requests and responses:

```typescript
// API request interceptor
axiosInstance.interceptors.request.use(
  (config) => {
    // Add authentication information
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// API response interceptor
axiosInstance.interceptors.response.use(
  (response) => response.data,
  (error) => {
    // Handle 401 unauthorized errors
    if (error.response?.status === 401) {
      // Redirect to login page
      window.location.href = '/signin'
    }
    return Promise.reject(error)
  }
)
```

### 3. API Path Management

The frontend configures API endpoints through environment variables, ensuring correct service access in different environments:

```javascript
// API endpoint configuration
const API_PREFIX = process.env.NEXT_PUBLIC_API_PREFIX
const PUBLIC_API_PREFIX = process.env.NEXT_PUBLIC_PUBLIC_API_PREFIX

// API path constructor
const getApiPath = (path, isPublicAPI = false) => {
  const prefix = isPublicAPI ? PUBLIC_API_PREFIX : API_PREFIX
  return `${prefix}${path}`
}
```

## Monitoring and Health Checks 🩺

### 1. Application Monitoring

The Web service integrates various monitoring solutions:

```typescript
// Sentry error monitoring configuration
if (process.env.NEXT_PUBLIC_SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
    integrations: [
      new BrowserTracing(),
      new Replay(),
    ],
    tracesSampleRate: 0.1,
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
  })
}
```

### 2. PM2 Monitoring

PM2 provides process monitoring and management capabilities, allowing you to check the Web service's operational status with the following commands:

```bash
# Enter the container
docker exec -it dify-web /bin/sh

# View PM2 process status
pm2 status

# View process logs
pm2 logs

# Monitor resource usage
pm2 monit
```

### 3. Health Checks and Fault Recovery

The Web service's health is jointly managed by Docker and PM2:

- **Docker restart policy**: `restart: always` ensures automatic restart when the container crashes
- **PM2 cluster mode**: Runs the application across multiple processes, automatically restarting when a single process crashes
- **PM2 load balancing**: Automatically distributes traffic across multiple processes

## Extensions and Customization 🛠️

### 1. Custom Themes

You can customize the UI theme by modifying Tailwind configuration and style variables:

```javascript
// Create custom Dockerfile
FROM langgenius/dify-web:0.15.3 AS base

# Copy custom configuration file
COPY ./custom-theme.css /app/web/styles/custom-theme.css

# Update environment variables to use custom theme
ENV NEXT_PUBLIC_USE_CUSTOM_THEME=true
```

### 2. Add Custom Pages

To add custom pages, you can build your own version based on the official image:

```Dockerfile
# Build stage
FROM node:18-alpine as builder

WORKDIR /app
# Clone source code from official repository
RUN git clone https://github.com/langgenius/dify.git --branch 0.15.3 .
WORKDIR /app/web

# Add custom pages
COPY ./custom-pages/ ./app/pages/custom/

# Install dependencies and build
RUN yarn install --frozen-lockfile
RUN yarn build

# Final stage - Maintain same structure as official image
FROM node:18-alpine

# Copy necessary files and build results
WORKDIR /app/web
COPY --from=builder /app/web/package*.json ./
COPY --from=builder /app/web/.next ./.next
COPY --from=builder /app/web/public ./public
COPY --from=builder /app/web/node_modules ./node_modules
# Copy startup scripts
COPY --from=builder /app/web/docker/pm2.json ./pm2.json
COPY --from=builder /app/web/docker/entrypoint.sh ./entrypoint.sh

# Install PM2
RUN yarn global add pm2

# Expose port and set entry point
EXPOSE 3000
ENTRYPOINT ["/bin/sh", "./entrypoint.sh"]
```

### 3. Multi-environment Deployment Configuration

You can configure different environment variables for different environments, such as testing and production:

```yaml
# docker-compose.override.yml - Development environment
services:
  web:
    environment:
      DEPLOY_ENV: DEVELOPMENT
      CONSOLE_API_URL: http://dev-api.example.com
      APP_API_URL: http://dev-app.example.com
      NEXT_PUBLIC_DEBUG: "true"

# docker-compose.prod.yml - Production environment
services:
  web:
    environment:
      DEPLOY_ENV: PRODUCTION
      CONSOLE_API_URL: https://api.example.com
      APP_API_URL: https://app.example.com
      NEXT_PUBLIC_DEBUG: "false"
```

## Common Issues and Solutions ❓

### 1. Slow or Incomplete Page Loading

**Issue**: Web interface loads slowly or some components don't display correctly

**Solutions**:
- Check network connection: Ensure Web service can access API service
- Verify environment variables: Ensure `CONSOLE_API_URL` and `APP_API_URL` are set correctly
- Clear browser cache: There may be outdated static resources
- Check container resources: Ensure container has sufficient CPU and memory resources

### 2. API Request Failures

**Issue**: Frontend displays API errors or data loading failures

**Solutions**:
- Check API service status: Confirm API service is running
- Verify network configuration: Check if container network is correctly set up
- Check CORS settings: Ensure API allows cross-origin requests from Web service
- View browser console: Check specific error messages

### 3. Incorrect UI Display

**Issue**: UI component styles are messy or functionality is abnormal

**Solutions**:
- Update browser: Ensure using the latest version of a modern browser
- Check CSS loading: See if any style files failed to load
- Disable browser extensions: Some extensions may interfere with page rendering
- Force refresh: Use Ctrl+F5 (or Cmd+Shift+R) to force refresh the page

### 4. PM2 Process Failure

**Issue**: Web service cannot start or frequently restarts

**Solutions**:
- Check PM2 logs: `docker exec -it dify-web /bin/sh -c "pm2 logs"`
- Verify Node.js version: Ensure container Node.js version is compatible with the application
- Check disk space: Ensure container and host have sufficient disk space
- Increase memory limit: Adjust container memory limit to accommodate application needs

### 5. Internationalization Not Working

**Issue**: Interface language cannot be switched or displays incorrectly

**Solutions**:
- Check browser language settings: Ensure browser language settings are correct
- Clear cookies: Some language preferences may be stored in cookies
- Verify language files: Check if relevant language resource files exist
- Manually switch language: Use the language selector in the UI to manually switch languages

---

## Related Links 🔗

- [Chinese Version](../【Dify】Web服务启动过程详解.md)
- [Dify API Service Startup Process Guide](【Dify】API服务启动过程详解.md)
- [Dify Docker-Compose Setup Guide](【Dify】Docker-Compose搭建过程详解.md)
- [Next.js Official Documentation](https://nextjs.org/docs)
- [PM2 Official Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/) 