-- 1. 防止成绩超出合理范围的触发器
DELIMITER //
CREATE TRIGGER tr_check_grade_range
BEFORE INSERT ON `选课成绩表`
FOR EACH ROW
BEGIN
    IF NEW.成绩 IS NOT NULL AND (NEW.成绩 < 0 OR NEW.成绩 > 100) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '成绩必须在0-100分之间';
    END IF;
END//
DELIMITER ;
-- 2. 防止学生入学年份超过当前年份的触发器
DELIMITER //
CREATE TRIGGER tr_check_enrollment_year
BEFORE INSERT ON `学生表`
FOR EACH ROW
BEGIN
    IF NEW.入学年份 > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '入学年份不能超过当前年份';
    END IF;
END//
DELIMITER ;


-- 3. 防止学分超出合理范围的触发器
DELIMITER //
CREATE TRIGGER tr_check_credit_range
BEFORE INSERT ON `课程表`
FOR EACH ROW
BEGIN
    IF NEW.学分 < 0 OR NEW.学分 > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '学分必须在0-10分之间';
    END IF;
    
    IF NEW.课时 < 0 OR NEW.课时 > 200 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '课时必须在0-200之间';
    END IF;
END//
DELIMITER ;

-- 4. 防止院系关系循环引用的触发器
DELIMITER //
CREATE TRIGGER tr_prevent_circular_dept
BEFORE UPDATE ON `系表`
FOR EACH ROW
BEGIN
    DECLARE ancestor_count INT;
    
    -- 简单的检查：不能设置为自己所属学院（这里实际上不会发生，因为外键不同表）
    -- 主要检查所属学院是否存在
    IF NEW.所属学院序号 IS NOT NULL THEN
        SELECT COUNT(*) INTO ancestor_count 
        FROM `学院表` 
        WHERE `序号` = NEW.所属学院序号;
        
        IF ancestor_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '所属学院不存在';
        END IF;
    END IF;
END//
DELIMITER ;

-- 5. 防止教师职称与职级不匹配的触发器
DELIMITER //
CREATE TRIGGER tr_check_teacher_title_consistency
BEFORE INSERT ON `教师表`
FOR EACH ROW
BEGIN
    -- 检查职称与职级的逻辑一致性
    IF NEW.职称 = '教授' AND NEW.职级 != '正高级' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '教授职称必须对应正高级职级';
    END IF;
    
    IF NEW.职称 = '副教授' AND NEW.职级 != '副高级' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '副教授职称必须对应副高级职级';
    END IF;
    
    IF NEW.职称 = '讲师' AND NEW.职级 NOT IN ('中级', '副高级') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '讲师职称应对应中级或副高级职级';
    END IF;
    
    IF NEW.职称 = '助教' AND NEW.职级 != '初级' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '助教职称必须对应初级职级';
    END IF;
END//
DELIMITER ;

-- 6. 教师表变更审计触发器
DELIMITER //
CREATE TRIGGER tr_audit_teacher_changes
AFTER INSERT ON `教师表`
FOR EACH ROW
BEGIN
    INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
    VALUES ('SYSTEM', CONCAT('新增教师:', NEW.教师姓名, ' (编号:', NEW.序号, ')'), '127.0.0.1');
END//

CREATE TRIGGER tr_audit_teacher_updates
AFTER UPDATE ON `教师表`
FOR EACH ROW
BEGIN
    IF OLD.职称 != NEW.职称 OR OLD.职级 != NEW.职级 THEN
        INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
        VALUES ('SYSTEM', CONCAT('更新教师职称/职级:', NEW.教师姓名, 
               ' 职称:', OLD.职称, '->', NEW.职称,
               ' 职级:', OLD.职级, '->', NEW.职级), '127.0.0.1');
    END IF;
END//

CREATE TRIGGER tr_audit_teacher_deletes
AFTER DELETE ON `教师表`
FOR EACH ROW
BEGIN
    INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
    VALUES ('SYSTEM', CONCAT('删除教师:', OLD.教师姓名, ' (编号:', OLD.序号, ')'), '127.0.0.1');
END//
DELIMITER ;

-- 7. 学生表变更审计触发器
DELIMITER //
CREATE TRIGGER tr_audit_student_changes
AFTER INSERT ON `学生表`
FOR EACH ROW
BEGIN
    INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
    VALUES ('SYSTEM', CONCAT('新增学生:', NEW.学生姓名, ' 学号:', NEW.学号), '127.0.0.1');
END//

CREATE TRIGGER tr_audit_student_deletes
AFTER DELETE ON `学生表`
FOR EACH ROW
BEGIN
    INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
    VALUES ('SYSTEM', CONCAT('删除学生:', OLD.学生姓名, ' 学号:', OLD.学号), '127.0.0.1');
END//
DELIMITER ;

-- 8. 成绩变更审计触发器（敏感操作详细记录）
DELIMITER //
CREATE TRIGGER tr_audit_grade_changes
AFTER UPDATE ON `选课成绩表`
FOR EACH ROW
BEGIN
    DECLARE student_name VARCHAR(10);
    DECLARE course_name VARCHAR(50);
    
    -- 获取学生姓名和课程名称
    SELECT `学生姓名` INTO student_name FROM `学生表` WHERE `序号` = NEW.学生序号;
    SELECT `课程名称` INTO course_name FROM `课程表` WHERE `序号` = NEW.课程序号;
    
    -- 记录成绩变更
    IF OLD.成绩 != NEW.成绩 THEN
        INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
        VALUES ('SYSTEM', CONCAT('成绩变更:', student_name, '的', course_name, 
               ' 成绩:', OLD.成绩, '->', NEW.成绩), '127.0.0.1');
    END IF;
END//

DELIMITER ;

-- 9. 教务处理状态变更审计
DELIMITER //
CREATE TRIGGER tr_audit_教务处理状态变更
AFTER UPDATE ON `教务处理明细表`
FOR EACH ROW
BEGIN
    IF OLD.处理状态 != NEW.处理状态 THEN
        INSERT INTO `系统操作日志` (`操作人`, `操作内容`, `IP地址`)
        VALUES ('SYSTEM', CONCAT('教务处理状态变更: 记录', NEW.序号, 
               ' ', OLD.处理状态, '->', NEW.处理状态), '127.0.0.1');
    END IF;
END//
DELIMITER ;
