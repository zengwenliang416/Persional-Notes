#!/usr/bin/env python3
"""
将截图转换为黑白并保存到当前目录
Convert a screenshot to black and white and save it to the current directory
"""

from PIL import Image
import os

def convert_to_bw(input_path, output_filename=None):
    """
    将图片转换为黑白并保存到当前目录
    Convert an image to black and white and save it to the current directory
    
    Args:
        input_path (str): 输入图片路径 (Path to input image)
        output_filename (str, optional): 输出图片文件名 (Output image filename)
            如果未提供，将使用"bw_screenshot.jpg" (If not provided, "bw_screenshot.jpg" will be used)
    
    Returns:
        str: 输出文件路径 (Path to output file)
    """
    # 如果未提供输出文件名，创建默认文件名
    # If output filename is not provided, create default filename
    if output_filename is None:
        output_filename = "bw_screenshot.jpg"
    
    # 创建当前目录下的输出路径
    # Create output path in the current directory
    output_path = os.path.join(os.getcwd(), output_filename)
    
    # 打开图片
    # Open the image
    img = Image.open(input_path)
    
    # 转换为黑白
    # Convert to black and white (grayscale)
    bw_img = img.convert('L')
    
    # 保存黑白图片到当前目录
    # Save the black and white image to the current directory
    bw_img.save(output_path)
    
    print(f"黑白图片已保存至当前目录: {output_path}")
    print(f"Black and white image saved to current directory: {output_path}")
    
    return output_path

if __name__ == "__main__":
    # 使用最近保存的截图路径
    # Use the path of the recently saved screenshot
    screenshot_path = "/Users/wenliang_zeng/screenshot.jpg"
    
    # 检查文件是否存在
    # Check if the file exists
    if os.path.exists(screenshot_path):
        # 转换为黑白并保存到当前目录
        # Convert to black and white and save to current directory
        output_path = convert_to_bw(screenshot_path)
    else:
        print(f"错误: 找不到截图文件 {screenshot_path}")
        print(f"Error: Screenshot file not found {screenshot_path}") 