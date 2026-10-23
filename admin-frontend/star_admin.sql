/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80031 (8.0.31)
 Source Host           : localhost:3306
 Source Schema         :  star-admin

 Target Server Type    : MySQL
 Target Server Version : 80031 (8.0.31)
 File Encoding         : 65001

 Date: 12/08/2026 19:01:27
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级部门ID，0=根节点',
  `ancestors` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '祖级列表（如 0,1,2）',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '部门名称',
  `order_num` int NOT NULL DEFAULT 0 COMMENT '排序号（值越小越靠前）',
  `leader` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常 0=禁用',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` tinyint NOT NULL DEFAULT 0 COMMENT '删除标记：0=正常 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (1, 0, '0', '总公司', 0, '张三', '13800138000', 'zonggongsi@test.com', 1, 'admin', '2026-08-12 17:07:41', NULL, NULL, 0);
INSERT INTO `sys_dept` VALUES (2, 1, '0,1', '研发部', 1, '李四', '13800138001', 'dev@test.com', 1, 'admin', '2026-08-12 17:07:41', NULL, NULL, 0);
INSERT INTO `sys_dept` VALUES (3, 1, '0,1', '市场部', 2, '王五', '13800138002', 'market@test.com', 1, 'admin', '2026-08-12 17:07:41', NULL, NULL, 0);
INSERT INTO `sys_dept` VALUES (4, 1, '0,1', '人事部', 3, '赵六', '13800138003', 'hr@test.com', 1, 'admin', '2026-08-12 17:07:41', NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级菜单ID，0=根节点',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `menu_type` tinyint NOT NULL DEFAULT 0 COMMENT '类型：0=目录 1=菜单 2=按钮',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标（Element Plus 图标名）',
  `order_num` int NOT NULL DEFAULT 0 COMMENT '排序号（值越小越靠前）',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由地址',
  `component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Vue 组件路径',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识（如 system:user:add）',
  `visible` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否可见：1=显示 0=隐藏',
  `is_cache` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否缓存：1=缓存 0=不缓存',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` tinyint NOT NULL DEFAULT 0 COMMENT '删除标记：0=正常 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_menu_type`(`menu_type` ASC) USING BTREE,
  INDEX `idx_perms`(`perms` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 63 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, 0, '系统管理', 0, 'Setting', 0, '/system', '', '', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (2, 0, '日志管理', 0, 'Document', 1, '/log', '', '', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (10, 1, '用户管理', 1, 'User', 0, 'user', 'system/user/UserList', 'system:user:list', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (11, 1, '角色管理', 1, 'Avatar', 1, 'role', 'system/role/RoleList', 'system:role:list', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (12, 1, '菜单管理', 1, 'Menu', 2, 'menu', 'system/menu/MenuList', 'system:menu:list', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (13, 1, '部门管理', 1, 'OfficeBuilding', 3, 'dept', 'system/dept/DeptList', 'system:dept:list', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (14, 2, '操作日志', 1, 'Document', 0, 'operlog', 'log/OperLog', 'system:log:list', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (20, 10, '新增用户', 2, '', 0, '', '', 'system:user:add', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (21, 10, '编辑用户', 2, '', 1, '', '', 'system:user:edit', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (22, 10, '删除用户', 2, '', 2, '', '', 'system:user:delete', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (23, 10, '导出用户', 2, '', 3, '', '', 'system:user:export', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (24, 10, '重置密码', 2, '', 4, '', '', 'system:user:resetPwd', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (25, 10, '分配角色', 2, '', 5, '', '', 'system:user:assignRole', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (30, 11, '新增角色', 2, '', 0, '', '', 'system:role:add', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (31, 11, '编辑角色', 2, '', 1, '', '', 'system:role:edit', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (32, 11, '删除角色', 2, '', 2, '', '', 'system:role:delete', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (33, 11, '分配权限', 2, '', 3, '', '', 'system:role:assignMenu', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (40, 12, '新增菜单', 2, '', 0, '', '', 'system:menu:add', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (41, 12, '编辑菜单', 2, '', 1, '', '', 'system:menu:edit', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (42, 12, '删除菜单', 2, '', 2, '', '', 'system:menu:delete', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (50, 13, '新增部门', 2, '', 0, '', '', 'system:dept:add', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (51, 13, '编辑部门', 2, '', 1, '', '', 'system:dept:edit', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (52, 13, '删除部门', 2, '', 2, '', '', 'system:dept:delete', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (60, 14, '删除日志', 2, '', 0, '', '', 'system:log:delete', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (61, 14, '清空日志', 2, '', 1, '', '', 'system:log:clear', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);
INSERT INTO `sys_menu` VALUES (62, 14, '导出日志', 2, '', 2, '', '', 'system:log:export', 1, 0, 'admin', '2026-08-12 17:08:32', NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作模块（如\"用户管理\"）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人员用户名',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP请求方式（GET/POST/PUT/DELETE）',
  `oper_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `oper_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作者IP地址',
  `oper_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP归属地（省市）',
  `oper_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数（JSON字符串）',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应结果（JSON字符串）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '操作状态：1=成功 0=失败',
  `cost_time` int NULL DEFAULT NULL COMMENT '接口耗时（毫秒）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '执行方法全路径',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息（成功时为NULL）',
  `oper_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_oper_name`(`oper_name` ASC) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_oper_time`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限标识（如 admin, editor）',
  `role_sort` int NOT NULL DEFAULT 0 COMMENT '排序号（值越小越靠前）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常 0=禁用',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` tinyint NOT NULL DEFAULT 0 COMMENT '删除标记：0=正常 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_key`(`role_key` ASC) USING BTREE,
  INDEX `idx_role_name`(`role_name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 0, 1, '拥有所有权限', 'admin', '2026-08-12 17:08:06', NULL, NULL, 0);
INSERT INTO `sys_role` VALUES (2, '普通用户', 'common', 1, 1, '仅查看权限', 'admin', '2026-08-12 17:08:06', NULL, NULL, 0);
INSERT INTO `sys_role` VALUES (3, '编辑员', 'editor', 2, 1, '可编辑内容', 'admin', '2026-08-12 17:08:06', NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE,
  INDEX `idx_menu_id`(`menu_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色-菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 1);
INSERT INTO `sys_role_menu` VALUES (1, 2);
INSERT INTO `sys_role_menu` VALUES (1, 10);
INSERT INTO `sys_role_menu` VALUES (1, 11);
INSERT INTO `sys_role_menu` VALUES (1, 12);
INSERT INTO `sys_role_menu` VALUES (1, 13);
INSERT INTO `sys_role_menu` VALUES (1, 14);
INSERT INTO `sys_role_menu` VALUES (1, 20);
INSERT INTO `sys_role_menu` VALUES (1, 21);
INSERT INTO `sys_role_menu` VALUES (1, 22);
INSERT INTO `sys_role_menu` VALUES (1, 23);
INSERT INTO `sys_role_menu` VALUES (1, 24);
INSERT INTO `sys_role_menu` VALUES (1, 25);
INSERT INTO `sys_role_menu` VALUES (1, 30);
INSERT INTO `sys_role_menu` VALUES (1, 31);
INSERT INTO `sys_role_menu` VALUES (1, 32);
INSERT INTO `sys_role_menu` VALUES (1, 33);
INSERT INTO `sys_role_menu` VALUES (1, 40);
INSERT INTO `sys_role_menu` VALUES (1, 41);
INSERT INTO `sys_role_menu` VALUES (1, 42);
INSERT INTO `sys_role_menu` VALUES (1, 50);
INSERT INTO `sys_role_menu` VALUES (1, 51);
INSERT INTO `sys_role_menu` VALUES (1, 52);
INSERT INTO `sys_role_menu` VALUES (1, 60);
INSERT INTO `sys_role_menu` VALUES (1, 61);
INSERT INTO `sys_role_menu` VALUES (1, 62);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录用户名',
  `password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加密后的密码（BCrypt）',
  `nick_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '所属部门ID',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `sex` tinyint NOT NULL DEFAULT 0 COMMENT '性别：0=男 1=女 2=未知',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常 0=禁用',
  `login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` tinyint NOT NULL DEFAULT 0 COMMENT '删除标记：0=正常 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_dept_id`(`dept_id` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$...加密后的密文...', '超级管理员', 1, '13800000000', 'admin@admin.com', 0, NULL, 1, NULL, NULL, '系统内置超级管理员', 'admin', '2026-08-12 17:09:08', NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);

SET FOREIGN_KEY_CHECKS = 1;
