-- 1. 创建统一用户表
CREATE TABLE IF NOT EXISTS `系统用户表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT,
  `用户名` VARCHAR(50) NOT NULL UNIQUE COMMENT '学号或工号',
  `密码` VARCHAR(100) NOT NULL DEFAULT 'Jwgl@2026',
  `角色` ENUM('admin', 'jwls', 'stu', 'xyfz', 'js') NOT NULL,
  `创建时间` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 创建操作日志表
CREATE TABLE IF NOT EXISTS `系统操作日志` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT,
  `操作人` VARCHAR(50),
  `操作内容` VARCHAR(255),
  `操作时间` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `IP地址` VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. 初始化一个管理员账号 (用户名: admin, 密码: Jwgl@2026)
INSERT IGNORE INTO `系统用户表` (用户名, 密码, 角色) VALUES ('admin', '123456', 'admin');