# 【Dify】Detailed Guide to Worker Service Startup Process 🚀

> This article provides a detailed analysis of the startup mechanism, task processing flow, and asynchronous job management of the Worker service in the Dify platform, helping users gain a deep understanding of how the platform's background task processing system works.

## Table of Contents 📑

- [Role of Worker Service in Dify](#role-of-worker-service-in-dify)
- [Docker-Compose Configuration Analysis](#docker-compose-configuration-analysis)
- [Image Building and Content](#image-building-and-content)
- [Startup Process](#startup-process)
- [Environment Variables and Configuration](#environment-variables-and-configuration)
- [Task Processing Mechanism](#task-processing-mechanism)
- [Interaction with Other Services](#interaction-with-other-services)
- [Monitoring and Health Checks](#monitoring-and-health-checks)
- [Extensions and Customization](#extensions-and-customization)
- [Common Issues and Solutions](#common-issues-and-solutions)

## Role of Worker Service in Dify 🔄

In the Dify architecture, the Worker service is responsible for handling all tasks that need asynchronous execution. It is a key component for ensuring platform performance and scalability. Its main responsibilities include:

1. **Asynchronous Task Processing**: Executing time-consuming operations such as document indexing and vector generation
2. **Scheduled Task Management**: Handling timed and periodic tasks such as data synchronization and cache updates
3. **Model Call Delegation**: Handling longer LLM inference requests
4. **Resource-Intensive Operations**: Executing memory or CPU-intensive tasks to avoid blocking the API service
5. **Retry and Fault Tolerance**: Providing automatic retry mechanisms for failed tasks
6. **Data Processing Pipeline**: Implementing complex data processing pipelines such as document import and content analysis

The Worker service shares the same codebase with the API service but runs in a different mode, focusing on background processing rather than directly responding to HTTP requests.

## Docker-Compose Configuration Analysis 🔍

```yaml
# Worker service
worker:
  image: langgenius/dify-api:0.15.3
  restart: always
  environment:
    # Using shared environment variables
    <<: *shared-api-worker-env
    # Startup mode, 'worker' starts Celery Worker
    MODE: worker
    SENTRY_DSN: ${API_SENTRY_DSN:-}
    SENTRY_TRACES_SAMPLE_RATE: ${API_SENTRY_TRACES_SAMPLE_RATE:-1.0}
    SENTRY_PROFILES_SAMPLE_RATE: ${API_SENTRY_PROFILES_SAMPLE_RATE:-1.0}
  depends_on:
    - db
    - redis
  volumes:
    # Mount storage directory to container for storing user files
    - ./volumes/app/storage:/app/api/storage
  networks:
    - ssrf_proxy_network
    - default
```

### Key Configuration Points Analysis:

1. **Image Version**: Uses the same image as the API service `langgenius/dify-api:0.15.3`
2. **Automatic Restart**: `restart: always` ensures automatic recovery when the service crashes
3. **Environment Variables**: Uses shared environment variable block (same as API service)
4. **Startup Mode**: Specifies Worker mode startup via `MODE: worker`
5. **Service Dependencies**: Also depends on db and redis services
6. **Data Storage**: Mounts the same storage directory, ensuring shared file access with the API service
7. **Networks**: Connects to multiple networks, implementing necessary communication and security isolation

## Image Building and Content 📦

The Worker service uses the same base image as the API service, including the following components:

### 1. Base Image Structure

```Dockerfile
# Uses the same Dockerfile as API service
FROM python:3.10

WORKDIR /app

# Copy dependency files
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY api/ /app/api/
COPY core/ /app/core/

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_APP=/app/api/app.py

# Set startup script
COPY docker/api/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
```

### 2. Main Components

- **Celery Worker**: Task queue processing system
- **SQLAlchemy**: ORM library for database interaction
- **Redis Client**: For interacting with message queue and cache
- **Vector Database Client**: For connecting to Weaviate or other vector databases
- **Document Processing Libraries**: For file parsing and text processing
- **Model Calling Libraries**: For interacting with various LLM provider APIs

## Startup Process 🚀

The Worker service startup process is similar to the API service but focuses on task processing rather than HTTP request handling:

### 1. Container Initialization

When Docker starts the Worker container, the entry point script (docker-entrypoint.sh) is executed:

```bash
#!/bin/bash
set -eo pipefail

# Wait for dependent services to be ready
wait-for-it ${DB_HOST}:${DB_PORT} -t 60
wait-for-it ${REDIS_HOST}:${REDIS_PORT} -t 60

# Choose startup command based on mode
if [ "$MODE" = "api" ]; then
    # API mode startup code (omitted)
elif [ "$MODE" = "worker" ]; then
    echo "Starting Celery worker..."
    
    # Set Celery worker class if necessary
    if [ -n "$CELERY_WORKER_CLASS" ]; then
        CELERY_WORKER_CLASS_OPT="-P $CELERY_WORKER_CLASS"
    else
        CELERY_WORKER_CLASS_OPT=""
    fi
    
    # Set number of worker processes
    if [ "$CELERY_AUTO_SCALE" = "true" ] && [ -n "$CELERY_MAX_WORKERS" ] && [ -n "$CELERY_MIN_WORKERS" ]; then
        # Auto-scaling mode
        CONCURRENCY_OPT="--autoscale=$CELERY_MAX_WORKERS,$CELERY_MIN_WORKERS"
    elif [ -n "$CELERY_WORKER_AMOUNT" ]; then
        # Fixed number of worker processes
        CONCURRENCY_OPT="--concurrency=$CELERY_WORKER_AMOUNT"
    else
        # Default number of worker processes (using available CPU cores)
        CONCURRENCY_OPT="--concurrency=$(nproc)"
    fi
    
    # Start Celery Worker
    exec celery -A api.celery_app.celery worker \
        $CELERY_WORKER_CLASS_OPT \
        $CONCURRENCY_OPT \
        --loglevel=INFO \
        --queues=dify \
        --hostname=worker@%h
else
    echo "Unknown mode: $MODE"
    exit 1
fi
```

### 2. Celery Application Initialization

In the `api.celery_app` module, the Celery application is initialized, connecting to the message broker and result backend:

```python
from celery import Celery
from api.config import Config

# Create Celery instance
celery = Celery('dify')

# Configure Celery
celery.conf.update(
    broker_url=Config.CELERY_BROKER_URL,
    result_backend=f"redis://{Config.REDIS_USERNAME}:{Config.REDIS_PASSWORD}@{Config.REDIS_HOST}:{Config.REDIS_PORT}/{Config.REDIS_DB}",
    task_track_started=True,
    task_time_limit=3600,  # Task timeout limit (seconds)
    worker_prefetch_multiplier=1,  # Number of tasks prefetched by each worker process
    task_acks_late=True,  # Acknowledge after task completion
    task_queues=['dify'],  # Task queue names
    task_default_queue='dify',  # Default queue
)

# Load task definitions
celery.autodiscover_tasks([
    'api.tasks.dataset_tasks',
    'api.tasks.app_tasks',
    'api.tasks.account_tasks',
    'api.tasks.conversation_tasks',
    'api.tasks.file_tasks',
    'api.tasks.system_tasks',
])
```

### 3. Task Registration and Discovery

Celery automatically discovers and registers all task definitions:

```python
# Example task in api/tasks/dataset_tasks.py
from api.celery_app import celery

@celery.task(bind=True, max_retries=3)
def process_dataset(self, dataset_id):
    """Dataset processing task"""
    try:
        # Execute dataset processing logic
        from api.services.dataset_service import DatasetService
        service = DatasetService()
        service.process_dataset(dataset_id)
    except Exception as e:
        # Retry on failure
        self.retry(exc=e, countdown=60)  # Retry after 60 seconds
```

### 4. Worker Startup

Finally, the Celery Worker starts and begins listening to the task queue:

- Queue name: `dify` (customizable)
- Number of worker processes: Controlled by `CELERY_WORKER_AMOUNT`, `CELERY_MAX_WORKERS`, and `CELERY_MIN_WORKERS`
- Worker process type: Specified by `CELERY_WORKER_CLASS` (optional)
- Hostname: `worker@%h` (%h is the hostname placeholder)

## Environment Variables and Configuration ⚙️

The Worker service uses numerous environment variables to customize its behavior, the most important of which include:

### 1. Celery Basic Configuration

```properties
# Celery message broker
CELERY_BROKER_URL=redis://:password@redis:6379/1
BROKER_USE_SSL=false

# Celery worker process configuration
CELERY_WORKER_CLASS=prefork  # Options: prefork, eventlet, gevent
CELERY_WORKER_AMOUNT=4       # Fixed number of worker processes
```

### 2. Auto-scaling Configuration

```properties
# Enable auto-scaling
CELERY_AUTO_SCALE=true
CELERY_MAX_WORKERS=8   # Maximum number of worker processes
CELERY_MIN_WORKERS=2   # Minimum number of worker processes
```

### 3. Task Execution Configuration

```properties
# Task execution limits
APP_MAX_EXECUTION_TIME=1200  # Maximum execution time (seconds)
APP_MAX_ACTIVE_REQUESTS=0    # Maximum number of active requests (0 means unlimited)
```

### 4. Security and Monitoring Configuration

```properties
# Sentry integration (error monitoring)
SENTRY_DSN=your-sentry-dsn-here
SENTRY_TRACES_SAMPLE_RATE=1.0
SENTRY_PROFILES_SAMPLE_RATE=1.0
```

## Task Processing Mechanism 🔄

The Worker service implements an efficient and reliable task processing flow:

### 1. Task Definition and Registration

Tasks are defined and registered in code using decorators:

```python
from api.celery_app import celery

@celery.task(
    name="index_document",  # Task name
    bind=True,              # Bind task instance for accessing task information
    max_retries=3,          # Maximum number of retries
    retry_backoff=True,     # Use exponential backoff when retrying
    acks_late=True          # Acknowledge after completion to avoid task loss
)
def index_document(self, file_id, dataset_id):
    """Index document to vector database"""
    try:
        # Task implementation...
        pass
    except Exception as e:
        # Log error and retry
        current_app.logger.error(f"Error indexing document: {str(e)}")
        self.retry(exc=e, countdown=min(2 ** self.request.retries * 60, 3600))
```

### 2. Task Distribution

The API service distributes tasks via the Celery client:

```python
# Distribute tasks in API service
from api.tasks.file_tasks import index_document

# Synchronous call (waiting for result)
result = index_document.apply_async(
    args=[file_id, dataset_id],
    queue='dify',              # Queue name
    priority=5,                # Priority
    countdown=0,               # Delayed execution (seconds)
    expires=3600,              # Expiration time (seconds)
    task_id=f"index_{file_id}" # Custom task ID
)

# Check task status
if result.ready():
    if result.successful():
        result_value = result.get()
    else:
        error = result.get(propagate=False)
```

### 3. Task Execution Flow

The general flow for Worker task execution:

1. Get task from message queue
2. Create task context and execution environment
3. Execute task logic, handling business requirements
4. Record task progress and results
5. Handle success or failure cases (including retry mechanisms)
6. Acknowledge task completion, removing it from the queue

### 4. Task Status Management

Task status is tracked and stored in Redis:

```python
# Update status in task
@celery.task(bind=True)
def long_running_task(self, task_params):
    # Initial status
    self.update_state(state="STARTED", meta={'progress': 0})
    
    # Process
    for i in range(10):
        # Execute partial work...
        
        # Update progress
        self.update_state(state="PROGRESS", meta={'progress': (i+1)*10})
    
    # Return final result
    return {'status': 'success', 'result': 'task completed'}
```

## Interaction with Other Services 🔌

The Worker service interacts with multiple components to complete tasks:

### 1. Database Interaction

Similar to the API service, Worker uses SQLAlchemy to interact with the database:

```python
from api.models import db, Dataset, Document
from sqlalchemy.orm import joinedload

def get_dataset_documents(dataset_id):
    # Use transaction
    with db.session.begin():
        dataset = Dataset.query.get(dataset_id)
        if not dataset:
            return None
        
        # Get related documents
        documents = Document.query.filter_by(
            dataset_id=dataset_id,
            status='ready'
        ).options(
            joinedload(Document.segments)
        ).all()
        
        return documents
```

### 2. Vector Database Interaction

Worker performs vector retrieval and storage operations:

```python
from api.core.vector_store.weaviate import WeaviateVectorStore

def index_document_segments(segments, document_id):
    """Index segments to vector database"""
    vector_store = WeaviateVectorStore()
    
    # Preprocess segments
    prepared_segments = []
    for segment in segments:
        prepared_segments.append({
            'id': segment.id,
            'content': segment.content,
            'document_id': document_id,
            'metadata': segment.metadata
        })
    
    # Batch insert vectors
    return vector_store.add_segments(prepared_segments)
```

### 3. File Storage Interaction

Process file uploads and access:

```python
from api.core.file.file_storage import FileStorage

def process_uploaded_file(file_id):
    """Process uploaded file"""
    storage = FileStorage()
    
    # Get file
    file_obj = storage.get_file(file_id)
    file_content = storage.get_file_content(file_id)
    
    # Process file content...
    
    # Save processing result
    result_file_id = storage.save_file(
        file_name='processed.json',
        file_content=json.dumps(result).encode('utf-8'),
        content_type='application/json'
    )
    
    return result_file_id
```

## Monitoring and Health Checks 🩺

### 1. Worker Monitoring

Celery Workers can be monitored through Flower:

```bash
# Add flower service in docker-compose.yaml
flower:
  image: mher/flower:0.9.7
  environment:
    - FLOWER_PORT=5555
    - FLOWER_BROKER_API=redis://:${REDIS_PASSWORD}@redis:6379/1
  ports:
    - "5555:5555"
  depends_on:
    - redis
    - worker
```

### 2. Log Monitoring

Worker logs contain detailed task execution information:

```bash
# View Worker logs
docker-compose logs worker

# Monitor Worker logs in real-time
docker-compose logs -f worker
```

### 3. Task Queue Monitoring

You can monitor the task queue status in Redis:

```python
def check_queue_status():
    """Check task queue status"""
    redis_client = redis.Redis(
        host=Config.REDIS_HOST,
        port=Config.REDIS_PORT,
        password=Config.REDIS_PASSWORD,
        db=Config.REDIS_DB
    )
    
    # Get queue information
    queue_length = redis_client.llen('celery')
    active_tasks = redis_client.hlen('celery-task-meta-')
    
    return {
        'queue_length': queue_length,
        'active_tasks': active_tasks
    }
```

## Extensions and Customization 🛠️

### 1. Adding Custom Tasks

You can extend Worker functionality by creating new task modules:

```python
# Add custom tasks in api/tasks/custom_tasks.py
from api.celery_app import celery
from api.services.my_service import MyService

@celery.task(bind=True)
def my_custom_task(self, param1, param2):
    """Custom task logic"""
    service = MyService()
    return service.do_something(param1, param2)
```

Then register in the Celery configuration:

```python
# Update celery.autodiscover_tasks
celery.autodiscover_tasks([
    # Existing tasks...
    'api.tasks.custom_tasks',  # Add custom task module
])
```

### 2. Customizing Task Priority

Set priorities for different task types:

```python
# Define priority constants
HIGH_PRIORITY = 9
NORMAL_PRIORITY = 5
LOW_PRIORITY = 1

# High priority task
@celery.task(bind=True, priority=HIGH_PRIORITY)
def important_task(self, data):
    # High priority processing logic...
    pass

# Low priority task
@celery.task(bind=True, priority=LOW_PRIORITY)
def background_task(self, data):
    # Low priority processing logic...
    pass
```

### 3. Configuring Task Routing

Route different types of tasks to different queues:

```python
# Add task routing in celery configuration
celery.conf.task_routes = {
    'api.tasks.dataset_tasks.*': {'queue': 'dataset'},
    'api.tasks.file_tasks.*': {'queue': 'file'},
    'api.tasks.app_tasks.*': {'queue': 'app'},
    'api.tasks.system_tasks.*': {'queue': 'system'},
}
```

Then start multiple Workers, each listening to a different queue:

```bash
# Dataset Worker
celery -A api.celery_app.celery worker --loglevel=INFO --queues=dataset --hostname=dataset@%h

# File processing Worker
celery -A api.celery_app.celery worker --loglevel=INFO --queues=file --hostname=file@%h
```

## Common Issues and Solutions ❓

### 1. Worker Fails to Start

**Issue**: Worker service fails to start normally

**Solutions**:
- Check Celery configuration: `docker-compose logs worker`
- Verify Redis connection: `docker-compose exec worker redis-cli -h redis ping`
- Confirm environment variable settings: especially `CELERY_BROKER_URL`
- Check if Python dependencies are complete: `docker-compose exec worker pip list | grep celery`

### 2. Tasks Stuck in Queue

**Issue**: Tasks are added to the queue but not executed

**Solutions**:
- Confirm Worker is running: `docker-compose ps worker`
- Check if Worker is listening to the correct queue: `docker-compose logs worker | grep "Connected to"`
- Verify task name and routing: ensure task name matches queue name
- Check if tasks have errors: `docker-compose logs worker | grep ERROR`

### 3. Slow Task Execution

**Issue**: Task execution time is too long

**Solutions**:
- Increase the number of Workers:
  ```
  CELERY_WORKER_AMOUNT=8  # Increase number of worker processes
  ```
- Enable concurrent processing (if tasks support it):
  ```
  CELERY_WORKER_CLASS=eventlet  # Use event-driven concurrency model
  ```
- Optimize database queries and batch processing logic
- Use task splitting strategy, breaking large tasks into multiple smaller ones

### 4. Frequent Task Failures

**Issue**: Tasks frequently fail and retry

**Solutions**:
- Check task logs to identify failure reasons: `docker-compose logs worker | grep -A 10 "Task.*failed"`
- Improve error handling and retry logic in tasks
- Increase resource allocation (such as memory):
  ```
  # Set resource limits in docker-compose.yaml
  worker:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
  ```
- Check if external service dependencies are reliable

### 5. Memory Leak Issues

**Issue**: Worker memory usage grows over time

**Solutions**:
- Set maximum number of tasks per Worker process:
  ```python
  celery.conf.worker_max_tasks_per_child = 100  # Restart worker process after processing 100 tasks
  ```
- Use prefork worker pool: `CELERY_WORKER_CLASS=prefork`
- Monitor memory usage: `docker stats worker`
- Periodically restart Worker: Use Kubernetes or other container orchestration tools to set up periodic restarts

---

## Related Links 🔗

- [Chinese Version](../【Dify】Worker服务启动过程详解.md)
- [Dify API Service Startup Process Guide](【Dify】API服务启动过程详解.md)
- [Dify Docker-Compose Setup Guide](【Dify】Docker-Compose搭建过程详解.md)
- [Celery Official Documentation](https://docs.celeryq.dev/)
- [Redis Official Documentation](https://redis.io/documentation) 