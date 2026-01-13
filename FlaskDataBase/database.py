from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# 定义用户模型以便登录验证
class User(db.Model):
    __tablename__ = '系统用户表'
    序号 = db.Column(db.Integer, primary_key=True)
    用户名 = db.Column(db.String(50), unique=True, nullable=False)
    密码 = db.Column(db.String(100), nullable=False)
    角色 = db.Column(db.String(20), nullable=False)