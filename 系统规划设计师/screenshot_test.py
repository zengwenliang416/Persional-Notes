import pyautogui
from PIL import Image
import os
import io

try:
    print('Taking screenshot...')
    screenshot = pyautogui.screenshot()
    print('Screenshot taken')
    
    # 转换为RGB模式并压缩
    screenshot = screenshot.convert('RGB')
    
    # 保存为压缩的JPEG格式
    output = io.BytesIO()
    screenshot.save(output, format='JPEG', quality=60, optimize=True)
    
    # 将压缩后的数据写入文件
    with open('screenshot.jpg', 'wb') as f:
        f.write(output.getvalue())
    
    print('Screenshot saved as screenshot.jpg')
    print('File size:', os.path.getsize('screenshot.jpg') / 1024 / 1024, 'MB')

except Exception as e:
    print('Error:', str(e)) 