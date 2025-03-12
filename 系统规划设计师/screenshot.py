"""
FastMCP Screenshot Example

Give Claude a tool to capture and view screenshots.
"""

import io
import os
from fastmcp import FastMCP, Image


# Create server
mcp = FastMCP("Screenshot Demo", dependencies=["pyautogui", "Pillow"])


@mcp.tool()
def take_screenshot() -> str:
    """
    Take a screenshot of the user's screen and return the file path of the saved image.
    """
    import pyautogui

    # 截图并保存到文件路径
    # Take the screenshot and save it to the file path
    screenshot = pyautogui.screenshot()
    screenshot.convert("RGB").save(os.path.join(os.path.expanduser('~'), 'screenshot.jpg'), format="JPEG", quality=60, optimize=True)

    # 返回保存截图的文件路径
    return os.path.join(os.path.expanduser('~'), 'screenshot.jpg')
