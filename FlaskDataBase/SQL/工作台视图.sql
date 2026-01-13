USE `大学教务管理系统`;
-- 批量删除可能存在的旧视图
DROP VIEW IF EXISTS `vw_超级管理员_工作台`;
DROP VIEW IF EXISTS `vw_学院负责人_工作台`;
DROP VIEW IF EXISTS `vw_系主任_工作台`;
DROP VIEW IF EXISTS `vw_教务老师_工作台主视图`;
DROP VIEW IF EXISTS `vw_教务老师_成绩录入专用视图`;
DROP VIEW IF EXISTS `vw_教务老师_待处理工作视图`;
DROP VIEW IF EXISTS `vw_授课教师_工作台`;
DROP VIEW IF EXISTS `vw_学生_个人信息视图`;
DROP VIEW IF EXISTS `vw_学生_选课成绩工作台`;
DROP VIEW IF EXISTS `vw_班主任_工作台`;
-- 1. 超级管理员工作台 (侧重于用户与基础资料管理)
CREATE OR REPLACE VIEW vw_超级管理员_工作台 AS
SELECT 
    yh.序号, -- 第一列设为主键，方便管理员直接删除/维护非法用户
    yh.用户名,
    yh.角色,
    yh.密码,
    (SELECT COUNT(*) FROM 系统用户表) AS 总用户量 -- 仅作为信息参考
FROM 系统用户表 yh
ORDER BY yh.序号 DESC;

-- 2. 学院负责人工作台
CREATE OR REPLACE VIEW vw_学院负责人_工作台 AS
SELECT 
    xy.序号, 
    xy.学院名称, 
    xy.负责人, 
    xy.联系电话,
    (SELECT COUNT(*) FROM 系表 WHERE 所属学院序号 = xy.序号) AS 下属系总数
FROM 学院表 xy;

-- 3. 系主任工作台 (聚焦本系教师管理)
CREATE OR REPLACE VIEW vw_系主任_工作台 AS
SELECT 
    js.序号, 
    js.教师姓名, 
    js.职称, 
    js.职级, 
    xs.系名称 AS 所属系部,
    js.办公地点
FROM 教师表 js
LEFT JOIN 系表 xs ON js.所属系序号 = xs.序号;

-- 4. 教务老师_工作台主视图 (侧重于明细记录的处理)
CREATE OR REPLACE VIEW vw_教务老师_工作台主视图 AS
SELECT 
    wcl.序号, 
    wcl.教务处理类型, 
    wcl.教务处理内容, 
    xs.学生姓名 AS 关联学生, 
    wcl.处理状态, 
    wcl.处理时间
FROM 教务处理明细表 wcl
LEFT JOIN 学生表 xs ON wcl.关联学生序号 = xs.序号
ORDER BY wcl.处理时间 DESC;

-- 5. 教务老师_成绩录入专用视图 (此视图用于前端“改分”逻辑)
CREATE OR REPLACE VIEW vw_教务老师_成绩录入专用视图 AS
SELECT 
    xkcj.序号, 
    stu.学生姓名, 
    stu.学号, 
    kc.课程名称, 
    xkcj.成绩, 
    xkcj.选课学期
FROM 选课成绩表 xkcj
JOIN 学生表 stu ON xkcj.学生序号 = stu.序号
JOIN 课程表 kc ON xkcj.课程序号 = kc.序号
WHERE xkcj.成绩 IS NULL OR xkcj.成绩 = ''; -- 仅显示待录入

-- 6. 教务老师_待处理工作视图
CREATE OR REPLACE VIEW vw_教务老师_待处理工作视图 AS
SELECT 
    wcl.序号, 
    wcl.教务处理类型, 
    wcl.教务处理内容, 
    wcl.处理状态,
    wcl.备注
FROM 教务处理明细表 wcl
WHERE wcl.处理状态 IN ('待处理', '审核中');

-- 7. 授课教师工作台 (教师查看自己课下的学生)
CREATE OR REPLACE VIEW vw_授课教师_工作台 AS
SELECT 
    xkcj.序号, 
    kc.课程名称, 
    stu.学生姓名, 
    stu.学号, 
    xkcj.成绩,
    js.教师姓名 AS 授课教师
FROM 选课成绩表 xkcj
JOIN 课程表 kc ON xkcj.课程序号 = kc.序号
JOIN 学生表 stu ON xkcj.学生序号 = stu.序号
JOIN 教师表 js ON kc.授课教师序号 = js.序号;

-- 8. 学生_个人信息视图
CREATE OR REPLACE VIEW vw_学生_个人信息视图 AS
SELECT 
    stu.序号, 
    stu.学生姓名, 
    stu.学号, 
    stu.班级, 
    xs.系名称 AS 所属系, 
    stu.联系电话
FROM 学生表 stu
LEFT JOIN 系表 xs ON stu.所属系序号 = xs.序号;

-- 9. 学生_选课成绩工作台
CREATE OR REPLACE VIEW vw_学生_选课成绩工作台 AS
SELECT 
    xkcj.序号, 
    kc.课程名称, 
    kc.学分, 
    xkcj.成绩, 
    xkcj.选课学期,
    stu.学生姓名 -- 用于权限过滤
FROM 选课成绩表 xkcj
JOIN 课程表 kc ON xkcj.课程序号 = kc.序号
JOIN 学生表 stu ON xkcj.学生序号 = stu.序号;

-- 10. 班主任_工作台
CREATE OR REPLACE VIEW vw_班主任_工作台 AS
SELECT 
    stu.序号, 
    stu.班级, 
    stu.学生姓名, 
    stu.学号, 
    stu.联系电话,
    xs.系名称 AS 所属系
FROM 学生表 stu
LEFT JOIN 系表 xs ON stu.所属系序号 = xs.序号;