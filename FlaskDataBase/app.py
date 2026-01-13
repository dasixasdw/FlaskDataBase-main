from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text, event

app = Flask(__name__)
app.secret_key = 'university_super_secret_safe_key_2026'

# 1. 数据库配置 (使用你的最新密码)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:Wyh_%400601_eki@127.0.0.1/大学教务管理系统?charset=utf8mb4'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# 2. 数据库兼容性修复
with app.app_context():
    @event.listens_for(db.engine, "connect")
    def disable_strict_mode(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        try:
            cursor.execute("SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))")
        except:
            pass
        cursor.close()

# 3. 核心配置：视图映射、物理表关联、可操作字段及权限控制
# student_filter: True 表示该视图需要根据当前登录的用户名(学号)进行行级过滤
TABLE_SCHEMAS = {
    'vw_超级管理员_工作台': {
        'table': '系统用户表',
        'fields': ['用户名', '密码', '角色'],
        'roles': ['admin'],
        'student_filter': False
    },
    'vw_学院负责人_工作台': {
        'table': '学院表',
        'fields': ['学院名称', '学院简称', '负责人', '联系电话'],
        'roles': ['admin'],
        'student_filter': False
    },
    'vw_教务老师_待处理工作视图': {
        'table': '教务处理明细表',
        'fields': ['教务处理类型', '教务处理内容', '处理状态'],
        'roles': ['admin', 'jwls'],
        'student_filter': False
    },
    'vw_教务老师_成绩录入专用视图': {
        'table': '选课成绩表',
        'fields': ['成绩', '备注'],
        'roles': ['admin', 'jwls'],
        'student_filter': False
    },
    'vw_学生_个人信息视图': {
        'table': '学生表',
        'fields': ['联系电话', '备注'],
        'roles': ['admin', 'stu'],
        'student_filter': True  # 学生只能查/改自己的记录
    },
    'vw_学生_选课成绩工作台': {
        'table': '选课成绩表',
        'fields': [],  # 成绩单通常对学生是只读的
        'roles': ['admin', 'stu'],
        'student_filter': True  # 学生只能看自己的成绩
    }
}


# --- 路由逻辑 ---

@app.route('/')
def index():
    return redirect(url_for('login'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        u = request.form.get('username')
        p = request.form.get('password')
        sql = text("SELECT * FROM 系统用户表 WHERE 用户名 = :u AND 密码 = :p")
        user = db.session.execute(sql, {'u': u, 'p': p}).fetchone()

        if user:
            session['user'] = user[1]  # 用户名 (学号/工号)
            session['role'] = user[3]  # 角色 (admin/jwls/stu)

            # 设置初始视图
            if user[3] == 'admin':
                session['current_view'] = 'vw_超级管理员_工作台'
            elif user[3] == 'jwls':
                session['current_view'] = 'vw_教务老师_待处理工作视图'
            else:
                session['current_view'] = 'vw_学生_个人信息视图'
            return redirect(url_for('dashboard'))

        flash("用户名或密码错误", "danger")
    return render_template('login.html')


@app.route('/dashboard')
def dashboard():
    if 'user' not in session: return redirect(url_for('login'))

    view_name = session.get('current_view')
    schema = TABLE_SCHEMAS.get(view_name, {'fields': [], 'roles': [], 'student_filter': False})

    # 动态构建查询：如果是学生且视图支持过滤，增加 WHERE 子句
    query_str = f"SELECT * FROM `{view_name}`"
    params = {}
    if session['role'] == 'stu' and schema['student_filter']:
        query_str += " WHERE `学号` = :u"
        params['u'] = session['user']

    result = db.session.execute(text(query_str), params)
    columns = list(result.keys())
    data = [list(row) for row in result.fetchall()]

    # 权限检查：当前角色是否允许在此视图进行操作
    can_operate = session['role'] in schema['roles']

    return render_template('dashboard.html',
                           columns=columns,
                           data=data,
                           current_view=view_name,
                           fields=schema['fields'] if can_operate else [],
                           role=session['role'])


@app.route('/switch_view/<vname>')
def switch_view(vname):
    if 'user' not in session: return redirect(url_for('login'))
    session['current_view'] = vname
    return redirect(url_for('dashboard'))


@app.route('/insert', methods=['POST'])
def insert():
    schema = TABLE_SCHEMAS.get(session.get('current_view'))
    if not schema or session['role'] not in schema['roles']:
        flash("权限不足", "danger")
        return redirect(url_for('dashboard'))

    fields = schema['fields']
    cols = ", ".join([f"`{f}`" for f in fields])
    vals = ", ".join([f":{f}" for f in fields])
    sql = text(f"INSERT INTO `{schema['table']}` ({cols}) VALUES ({vals})")

    try:
        db.session.execute(sql, {f: request.form.get(f) for f in fields})
        db.session.commit()
        flash("新增成功", "success")
    except Exception as e:
        db.session.rollback()
        flash(f"失败: {str(e)}", "danger")
    return redirect(url_for('dashboard'))


@app.route('/update', methods=['POST'])
def update():
    view_name = session.get('current_view')
    schema = TABLE_SCHEMAS.get(view_name)
    if not schema or session['role'] not in schema['roles']:
        flash("无权限修改", "danger")
        return redirect(url_for('dashboard'))

    target_id = request.form.get('target_id')
    fields = schema['fields']

    # 动态构建更新语句，学生角色强制加学号校验，防止越权修改
    set_clause = ", ".join([f"`{f}`=:{f}" for f in fields])
    where_clause = "WHERE `序号` = :tid"
    params = {f: request.form.get(f) for f in fields}
    params['tid'] = target_id

    if session['role'] == 'stu' and schema['student_filter']:
        where_clause += " AND `学号` = :u"
        params['u'] = session['user']

    sql = text(f"UPDATE `{schema['table']}` SET {set_clause} {where_clause}")

    try:
        res = db.session.execute(sql, params)
        db.session.commit()
        if res.rowcount == 0:
            flash("操作无效：您无权修改此记录或记录不存在", "warning")
        else:
            flash("更新成功", "success")
    except Exception as e:
        db.session.rollback()
        flash(f"错误: {str(e)}", "danger")
    return redirect(url_for('dashboard'))


@app.route('/delete/<int:id>')
def delete(id):
    view_name = session.get('current_view')
    schema = TABLE_SCHEMAS.get(view_name)
    # 学生不允许删除任何数据，仅管理员和教务老师在特定视图可以
    if not schema or session['role'] == 'stu' or session['role'] not in schema['roles']:
        flash("权限不足，无法删除", "danger")
        return redirect(url_for('dashboard'))

    sql = text(f"DELETE FROM `{schema['table']}` WHERE `序号` = :tid")
    try:
        db.session.execute(sql, {'tid': id})
        db.session.commit()
        flash("记录已删除", "warning")
    except Exception as e:
        db.session.rollback()
        flash("删除失败，可能存在外键关联", "danger")
    return redirect(url_for('dashboard'))


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


if __name__ == '__main__':
    app.run(debug=True)