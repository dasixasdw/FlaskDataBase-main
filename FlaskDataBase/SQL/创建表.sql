CREATE SCHEMA '大学教务管理系统'DEFAULT CHARACTER SET utf8mb4;
-- 1. 学院表
CREATE TABLE IF NOT EXISTS `学院表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，学院编号',
  `学院名称` VARCHAR(50) NOT NULL COMMENT '学院名称，如：计算机科学与技术学院',
  `学院简称` VARCHAR(20) NOT NULL COMMENT '学院简称，如：计算机学院',
  `负责人` VARCHAR(10) NOT NULL COMMENT '学院主任/院长',
  `联系电话` VARCHAR(20) COMMENT '学院办公电话',
  `备注` VARCHAR(200) COMMENT '学院说明备注'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-学院信息表';

-- 2. 系表 
CREATE TABLE IF NOT EXISTS `系表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，系编号',
  `系名称` VARCHAR(50) NOT NULL COMMENT '系名称，如：软件工程系',
  `系简称` VARCHAR(20) NOT NULL COMMENT '系简称，如：软件系',
  `所属学院序号` INT NOT NULL COMMENT '关联学院表的学院编号',
  `负责人` VARCHAR(10) NOT NULL COMMENT '系主任',
  `联系电话` VARCHAR(20) COMMENT '系办公电话',
  `备注` VARCHAR(200) COMMENT '系说明备注',
  FOREIGN KEY (`所属学院序号`) REFERENCES `学院表`(`序号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-系信息表';

-- 3. 教师表 
CREATE TABLE IF NOT EXISTS `教师表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，教师编号',
  `教师姓名` VARCHAR(10) NOT NULL COMMENT '教师姓名，如：张三',
  `性别` VARCHAR(2) NOT NULL COMMENT '教师性别，如：男/女',
  `职称` VARCHAR(20) NOT NULL COMMENT '教师职称，如：教授/讲师/助教',
  `职级` VARCHAR(20) NOT NULL COMMENT '教师职级，如：正高级/副高级/中级/初级',
  `所属系序号` INT NOT NULL COMMENT '关联系表的系编号',
  `联系电话` VARCHAR(20) COMMENT '教师联系电话',
  `办公地点` VARCHAR(50) COMMENT '教师办公地点，如：计算机楼302室',
  `备注` VARCHAR(200) COMMENT '教师说明备注',
  FOREIGN KEY (`所属系序号`) REFERENCES `系表`(`序号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-教师信息表';

-- 4. 教务表 
CREATE TABLE IF NOT EXISTS `教务表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，教务工作编号',
  `教务老师序号` INT NOT NULL COMMENT '关联教师表的教师编号，教务老师为教师表人员',
  `分管系序号` INT NOT NULL COMMENT '关联系表的系编号，分管对应系教务工作',
  `负责教务内容` VARCHAR(100) NOT NULL COMMENT '教务处理工作，如：排课/成绩录入/学籍管理/选课审核',
  `办公电话` VARCHAR(20) COMMENT '教务办公电话',
  `办公地点` VARCHAR(50) COMMENT '教务办公地点，如：行政楼205室',
  `备注` VARCHAR(200) COMMENT '教务工作说明备注',
  FOREIGN KEY (`教务老师序号`) REFERENCES `教师表`(`序号`),
  FOREIGN KEY (`分管系序号`) REFERENCES `系表`(`序号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-教务处理信息表';

-- 5. 学生表 
CREATE TABLE IF NOT EXISTS `学生表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，学生编号',
  `学生姓名` VARCHAR(10) NOT NULL COMMENT '学生姓名，如：李四',
  `性别` VARCHAR(2) NOT NULL COMMENT '学生性别，如：男/女',
  `学号` VARCHAR(20) NOT NULL UNIQUE COMMENT '学生学号，如：2025010101',
  `所属系序号` INT NOT NULL COMMENT '关联系表的系编号',
  `班级` VARCHAR(20) NOT NULL COMMENT '学生班级，如：计科2501班',
  `学生年级` VARCHAR(20) NOT NULL COMMENT '学生年级，如：大一/大二/大三/大四/研一',
  `学生职务` VARCHAR(20) COMMENT '学生职务，如：班长/学习委员/团支书/无',
  `入学年份` YEAR NOT NULL COMMENT '入学年份，如：2025',
  `联系电话` VARCHAR(20) COMMENT '学生联系电话',
  `备注` VARCHAR(200) COMMENT '学生说明备注',
  FOREIGN KEY (`所属系序号`) REFERENCES `系表`(`序号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-学生信息表';

-- 6. 课程表 
CREATE TABLE IF NOT EXISTS `课程表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，课程编号',
  `课程名称` VARCHAR(50) NOT NULL COMMENT '课程名称，如：数据库原理及应用',
  `课程简称` VARCHAR(20) NOT NULL COMMENT '课程简称，如：数据库原理',
  `授课教师序号` INT NOT NULL COMMENT '关联教师表的教师编号',
  `学分` INT NOT NULL COMMENT '课程学分，如：3',
  `课时` INT NOT NULL COMMENT '课程课时，如：48',
  `课程类型` VARCHAR(20) NOT NULL COMMENT '课程类型，如：必修课/选修课',
  `备注` VARCHAR(200) COMMENT '课程说明备注',
  FOREIGN KEY (`授课教师序号`) REFERENCES `教师表`(`序号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-课程信息表';

-- 7. 教务处理明细表 
CREATE TABLE IF NOT EXISTS `教务处理明细表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，教务明细记录编号',
  `所属教务序号` INT NOT NULL COMMENT '关联教务表的教务工作编号，归属对应教务老师',
  `关联学生序号` INT COMMENT '关联学生表的学生编号，无则留空，如：学籍/成绩相关业务',
  `关联课程序号` INT COMMENT '关联课程表的课程编号，无则留空，如：排课/选课相关业务',
  `教务处理类型` VARCHAR(20) NOT NULL COMMENT '教务处理类别，如：学籍管理/成绩录入/选课审核/排课安排',
  `教务处理内容` VARCHAR(200) NOT NULL COMMENT '教务处理详情，如：录入23级计科班高数成绩/审核李四选课申请/办理张三学籍异动',
  `处理时间` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '教务处理完成时间，默认当前系统时间',
  `处理状态` VARCHAR(10) NOT NULL COMMENT '处理状态，如：已完成/待处理/审核中/驳回',
  `备注` VARCHAR(200) COMMENT '教务明细备注信息',
  FOREIGN KEY (`所属教务序号`) REFERENCES `教务表`(`序号`),
  FOREIGN KEY (`关联学生序号`) REFERENCES `学生表`(`序号`),
  FOREIGN KEY (`关联课程序号`) REFERENCES `课程表`(`序号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-教务处理明细记录表';

-- 8. 选课成绩表 
CREATE TABLE IF NOT EXISTS `选课成绩表` (
  `序号` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键自增，选课成绩编号',
  `学生序号` INT NOT NULL COMMENT '关联学生表的学生编号',
  `课程序号` INT NOT NULL COMMENT '关联课程表的课程编号',
  `成绩` DECIMAL(5,2) COMMENT '课程成绩，如：89.50',
  `选课学期` VARCHAR(20) NOT NULL COMMENT '选课学期，如：2025-2026学年第一学期',
  `备注` VARCHAR(200) COMMENT '成绩说明备注',
  FOREIGN KEY (`学生序号`) REFERENCES `学生表`(`序号`),
  FOREIGN KEY (`课程序号`) REFERENCES `课程表`(`序号`),
  UNIQUE KEY `唯一选课记录` (`学生序号`,`课程序号`) COMMENT '一个学生只能选同一门课一次'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大学教务管理系统-学生选课成绩信息表';