from sqlalchemy import create_engine, text

# 替换为你实际的密码
DB_URI = 'mysql+pymysql://root:Wyh_%400601_eki@localhost/大学教务管理系统?charset=utf8mb4'

engine = create_engine(DB_URI)

try:
    # 尝试连接并执行一个简单的查询
    with engine.connect() as connection:
        result = connection.execute(text("SELECT 1"))
        print("✅ 数据库连接成功！配置正确。")
except Exception as e:
    print("❌ 连接失败，请检查配置。")
    print(f"具体错误信息: {e}")