USE `大学教务管理系统`;
FLUSH PRIVILEGES;

-- ===================== 1. 超级系统管理员 (最高权限，仅查超级管理员工作台) =====================
CREATE USER IF NOT EXISTS 'sys_admin'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_超级管理员_工作台 TO 'sys_admin'@'%';

-- ===================== 2. 学院负责人 (仅查学院负责人工作台) =====================
CREATE USER IF NOT EXISTS 'xyfz_01'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_学院负责人_工作台 TO 'xyfz_01'@'%';

-- ===================== 3. 系主任 (仅查系主任工作台) =====================
CREATE USER IF NOT EXISTS 'xizh_01'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_系主任_工作台 TO 'xizh_01'@'%';

-- ===================== 4. 教务老师 (核心权限，3个视图全授权) =====================
CREATE USER IF NOT EXISTS 'jwls_01'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_教务老师_工作台主视图 TO 'jwls_01'@'%';
GRANT SELECT ON `大学教务管理系统`.vw_教务老师_成绩录入专用视图 TO 'jwls_01'@'%';
GRANT SELECT ON `大学教务管理系统`.vw_教务老师_待处理工作视图 TO 'jwls_01'@'%';

-- ===================== 5. 授课教师 (仅查授课教师工作台) =====================
CREATE USER IF NOT EXISTS 'js_001'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_授课教师_工作台 TO 'js_001'@'%';

-- ===================== 6. 学生 (2个专属视图授权) =====================
CREATE USER IF NOT EXISTS 'stu_20250101'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_学生_个人信息视图 TO 'stu_20250101'@'%';
GRANT SELECT ON `大学教务管理系统`.vw_学生_选课成绩工作台 TO 'stu_20250101'@'%';

-- ===================== 7. 班主任 (仅查班主任工作台) =====================
CREATE USER IF NOT EXISTS 'bzr_01'@'%' IDENTIFIED BY 'Jwgl@2026';
GRANT SELECT ON `大学教务管理系统`.vw_班主任_工作台 TO 'bzr_01'@'%';

-- 刷新权限，立即生效
FLUSH PRIVILEGES;