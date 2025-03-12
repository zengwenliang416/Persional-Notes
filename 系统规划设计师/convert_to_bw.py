#!/usr/bin/env python3
"""
将截图转换为黑白并保存到本地
Convert a screenshot to black and white and save it locally
"""

from PIL import Image
import os

def convert_to_bw(input_path, output_path=None):
    """
    将图片转换为黑白并保存
    Convert an image to black and white and save it
    
    Args:
        input_path (str): 输入图片路径 (Path to input image)
        output_path (str, optional): 输出图片路径 (Path to output image)
            如果未提供，将在输入文件名前添加"bw_"前缀 (If not provided, "bw_" will be added to the input filename)
    
    Returns:
        str: 输出文件路径 (Path to output file)
    """
    # 如果未提供输出路径，创建默认输出路径
    # If output path is not provided, create default output path
    if output_path is None:
        directory = os.path.dirname(input_path)
        filename = os.path.basename(input_path)
        name, ext = os.path.splitext(filename)
        output_path = os.path.join(directory, f"bw_{name}{ext}")
    
    # 打开图片
    # Open the image
    img = Image.open(input_path)
    
    # 转换为黑白
    # Convert to black and white (grayscale)
    bw_img = img.convert('L')
    
    # 保存黑白图片
    # Save the black and white image
    bw_img.save(output_path)
    
    print(f"黑白图片已保存至: {output_path}")
    print(f"Black and white image saved to: {output_path}")
    
    return output_path

if __name__ == "__main__":
    # 使用最近保存的截图路径
    # Use the path of the recently saved screenshot
    screenshot_path = "/Users/wenliang_zeng/screenshot.jpg"
    
    # 检查文件是否存在
    # Check if the file exists
    if os.path.exists(screenshot_path):
        # 转换为黑白并保存
        # Convert to black and white and save
        output_path = convert_to_bw(screenshot_path)
    else:
        print(f"错误: 找不到截图文件 {screenshot_path}")
        print(f"Error: Screenshot file not found {screenshot_path}") 