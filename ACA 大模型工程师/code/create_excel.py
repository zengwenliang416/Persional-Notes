from openpyxl import Workbook

# 创建一个新的Excel工作簿
wb = Workbook()
sheet = wb.active

# 添加表头
sheet['A1'] = '用户反馈'

# 添加样本数据
sample_feedback = [
    "性价比不高，我觉得不值这个价钱",
    "客服回复太慢了，等了两天才收到回复",
    "产品质量还可以，但是操作起来太复杂了",
    "包装不够结实，运输过程中有损坏",
    "价格太贵了，同类产品便宜很多",
    "售后服务态度很差，问题一直没解决",
    "使用体验很差，界面特别不友好",
    "系统经常崩溃，影响使用",
    "价格超出预算太多",
    "技术支持响应太慢，问题一直得不到解决"
]

# 将数据写入Excel
for i, feedback in enumerate(sample_feedback, start=2):
    sheet[f'A{i}'] = feedback

# 保存Excel文件
wb.save('data/file_path_feedback.xlsx')
print("Excel文件已创建成功！")
