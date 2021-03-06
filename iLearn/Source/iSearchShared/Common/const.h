//
//  const.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_const_h
#define iSearch_const_h

// 主界面左侧导航按钮Tag
typedef NS_ENUM(NSInteger, EntryButtonTag){
    EntryButtonHomePage     = 0,
    EntryButtonFavorite     = 1,
    EntryButtonNotification = 2,
    EntryButtonSetting      = 3,
    EntryButtonDownload     = 4
};

// HomePage GridViewTag
typedef NS_ENUM(NSInteger, GridViewTag){
    GridViewOne     = 10,
    GridViewTwo     = 11,
    GridViewThree   = 12
};

// 演示文稿 编辑面板 伸缩按钮
typedef NS_ENUM(NSInteger, SlideEditPanelTag){
    SlideEditPanelHiden = 10,
    SlideEditPanelShow  = 11
};

// 通告、预告
typedef NS_ENUM(NSInteger, NotificationTableViewTag){
    NotificationTableViewONE = 10,
    NotificationTableViewTWO = 11
};
// 文档演示/编辑类型:收藏、正常文档
typedef NS_ENUM(NSInteger, SlideType){
    SlideTypeSlide = 10,
    SlideTypeFavorite = 11
};
typedef NS_ENUM(NSInteger, DisplayFromType){
    DisplayFromSlide = 10,
    DisplayFromOfflineCell = 11
};
// 目录排序
typedef NS_ENUM(NSInteger, SortType){
    SortByAscending = 10,
    SortByDescending = 11
};
// 目录过滤
typedef NS_ENUM(NSInteger, FilterType){
    FilterAll = 10,
    FilterCategory = 11,
    FilterSlide = 12
};
typedef NS_ENUM(NSInteger, CourseSigninType) {
    CourseSigninTypeSignin = 0,
    CourseSigninTypeArriveLate = 1,
    CourseSigninTypeLeaveEarly = 2
};

static NSString *const kPackageCourse     = @"PackageCourse";
static NSString *const kPackageQuestion   = @"PackageQuestion";
static NSString *const kPackageExam       = @"PackageExam";
static NSString *const kPackageCourseWrap = @"PackageCourseWrap";

/**
 *  TextFieldTag
 *
 * 离线搜索， 有TextFild ValueChaged监听， 但presentView显示Display,
 * 在presentView显示编辑界面, 选择收藏，输入框信息，会被监听误收
 *
 * **重点** 勿从0开始，因为默认tag=0
 */
typedef NS_ENUM(NSInteger, TextFieldTag){
    TextFieldSearchDB  = 10,
    TextFieldNewTagName = 11
};

// Global
#define PARAM_LANG              @"lang" // 传递给服务器的语言key
#define APP_LANG                @"zh-CN" // 应用系统的语言
#define BASE_URL                @"http://tsa-china.takeda.com.cn" //
#define BASE_PATH               @"uat" // 传递给服务器的语言key
#define CONFIG_DIRNAME          @"Configs" // 所有配置档放置在些文件夹下
#define DATE_FORMAT             @"yyyy/MM/dd HH:mm:ss" // 用户验证时，用到时间字符串时的存储格式
#define DATE_SIMPLE_FORMAT      @"yyyy/MM/dd" // 公告通知api使用及日历控件
#define NEW_TAG_FORMAT          @"yyMMddHHMMss" // 创建新标签后新文件名称格式
#define LOCAL_OR_SERVER_LOCAL   @"local" // 获取服务器信息或本地缓存
#define LOCAL_OR_SERVER_SREVER  @"server"// 获取服务器信息或本地缓存
#define DATABASE_DIRNAME        @"Database" // 数据库文件存放的文件夹名称
#define DATABASE_FILEAME        @"iSearch.sqlite3" // 数据库实体存放的文件名称（后缀.sqlite3）
#define CONTENT_ROOT_ID         @"1" // 获取目录分类的入口
#define THUMBNAIL_DIRNAME       @"Thumbails" // 分类缩略图
#define CACHE_DIRNAME           @"Caches"
#define UPGRADE_CONFIG_FILENAME @"upgrade.json"
#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]

// ActionLogger
#define ACTION_LOGGER_URL_PATH @"/api/logjson.php"

#define SIZE_GRID_VIEW_CELL_WIDTH     120 // GridView Cell‘s width
#define SIZE_GRID_VIEW_CELL_HEIGHT    80 // GridView Cell‘s width
//  w:427  h:375 间距:20
#define SIZE_GRID_VIEW_PAGE_WIDTH     184 // 文档页面编辑时GridView Cell width
#define SIZE_GRID_VIEW_PAGE_HEIGHT    184 // 文档页面编辑时GridView Cell height
#define SIZE_IMAGE_COVER_HEIGHT       134 // Cell由imageCover/labelTitle上下两部分组成
#define SIZE_LABEL_TITLE_HEIGHT       50
#define SIZE_GRID_VIEW_PAGE_MARGIN    20/2 // 文档页面编辑时GridView Cell 间距

#define GRID_VIEW_DELETE_BTN_OFFSET_X -15 // GridView Delete按钮平移位置
#define GRID_VIEW_DELETE_BTN_OFFSET_Y -15 // GridView Delete按钮平移位置
#define GRID_VIEW_DELETE_BTN_IMAGE    @"close_x.png" // GridView Delete按钮背影图片

// 登陆相关
#define LOGIN_URL_PATH         @"/api/users_api.php" // 用户身份验证的url路径
#define LOGIN_CONFIG_FILENAME  @"login.json" // 用户验证成功后，信息写入该配置档
#define LOGIN_KEEP_HOURS       24 // 用户在线登陆成功后，可LOGIN_KEEP_HOURS小时内[离线登陆]
#define LOGIN_DATE_FORMAT      @"yyyy/MM/dd HH:mm:ss" // 用户验证时，用到时间字符串时的存储格式
#define LOGIN_LAST_DEFAULT     @"1970/01/01 00:00:00" // 用户登陆前的默认登陆成功时间
// API参数
#define LOGIN_PARAM_UID        @"eid"
// API字段
#define LOGIN_FIELD_STATUS     @"status" // 为1则交互成功
#define LOGIN_FIELD_ID         @"Id"
#define LOGIN_FIELD_NAME       @"Name"
#define LOGIN_FIELD_EMAIL      @"Email"
#define LOGIN_FIELD_EMPLOYEEID @"EmployeeId"
#define LOGIN_FIELD_DEPTID     @"DeptId"
#define LOGIN_FIELD_RESULT     @"result"
// 通用字段
#define USER_ID                @"UserID"
#define USER_NAME              @"UserName"
#define USER_EMAIL              @"UserEmail"
#define USER_DEPTID            @"UserDeptID"
#define USER_EMPLOYEEID        @"UserEmployeeID"
#define USER_LOGIN_USERNAME    @"LoginUserName"
#define USER_LOGIN_PASSWORD    @"LoginPassword"
#define USER_LOGIN_REMEMBER_PWD  @"LoginRememberPWD"
#define USER_LOGIN_LAST        @"LoginLastTime"

// 目录相关(_FILE与获取文件相关，默认获取分类)
#define CONTENT_URL_PATH          @"/api/Categories_Api.php" // 请求目录的url路径
#define CONTENT_FILE_URL_PATH     @"/api/Files_Api.php" // 请求目录的url路径
#define CONTENT_DOWNLOAD_URL_PATH @"/api/Filedown_Api.php"
#define CONTENT_DIRNAME           @"Contents" // [目录]成功取得后，写入本地缓存文件夹
#define DOWNLOAD_DIRNAME          @"Downloads"// [目录]中[文件]压缩包下载文件夹
#define SLIDE_DIRNAME             @"Files"   // [目录]中[文件]压缩包下载成功解压至该文件夹
#define CONTENT_CONFIG_FILENAME   @"content.json" // 目录同步功能中，界面切换传递参数使用plist配置档
// 目录Config中key
#define CONTENT_KEY_DISPLAYID   @"DisplaySlideID" // 目录中文件已经下载，点击[演示]时通过该key传值
#define CONTENT_KEY_NAVSTACK    @"NavStack" // 用户点击目录行为记录 - 栈 NSMuataleArray
#define SLIDE_DISPLAY_TYPE      @"DisplayFavoriteOrSlide" // 下载文档位置不同
#define SLIDE_DISPLAY_FROM      @"DisplayFromType"
#define SCAN_SLIDE_FROM         @"ScanFavoriteOrSlide" // 下载文档位置不同
#define SCAN_SLIDE_ID           @"ScanSlideID" // 演示档时，[编辑]进入文档页面界面
#define SCAN_SLIDE_PAGEID       @"ScanSLidePageID" // 演示档时，[编辑]进入文档页面界面
#define SLIDE_DISPLAY_JUMPTO    @"DisplayJumpTo" // 编辑界面，双击进入演示
// 目录中文件类型
#define CONTENT_CATEGORY   @"0" // 分类，可以点击再进入
#define CONTENT_SLIDE      @"1" // 文献 （待确认)
#define CONTENT_PPT        @"2" // 幻灯片（待确认)
#define CONTENT_SORT_KEY   @"SortKey" // CONTENT_FIELD_ID转化为数字
// 目录API参数
#define CONTENT_PARAM_DEPTID    @"did" // 部门ID
#define CONTENT_PARAM_PARENTID  @"pid" // 分类父ID
#define CONTENT_PARAM_FILE_CATEGORYID @"cid" // 待加载分类ID
#define CONTENT_PARAM_FILE_DWONLOADID @"fid" // 下载文件ID
// 目录API字段
#define CONTENT_FIELD_DATA       @"data" // 数据数组
#define CONTENT_FIELD_ID         @"Id" // 分类ID
#define CONTENT_FIELD_NAME       @"Name" // 分类名称
#define CONTENT_FIELD_TITLE      @"Title" // 分类名称
#define CONTENT_FIELD_DESC       @"Desc" // 创建时间
#define CONTENT_FIELD_CREATEDATE @"EditTime" // 创建时间
#define CONTENT_FIELD_TYPE       @"Type" // 类型: 0为目录，1为文件
#define CONTENT_FIELD_CATEGORYID @"CategoryId"
#define CONTENT_FIELD_CATEGORYNAME @"CategoryName"
#define CONTENT_FIELD_ZIPSIZE    @"ZipSize"
#define CONTENT_FIELD_PAGENUM    @"PageNo"
#define CONTENT_FIELD_URL        @"DownloadUrl" // 文件下载链接，代码拼接而成

// 离线搜索/批量下载
#define OFFLINE_URL_PATH         @"/api/filelist_api.php" // 在线时获取服务器端文件列表数据，以备离线时搜索使用
#define OFFLINE_DIRNAME          @"Offlines"
// API参数
#define OFFLINE_PARAM_DEPTID     @"did"
// API字段
// shared with CONTENT_FIELD_*
// 数据库表字段
#define OFFLINE_TABLE_NAME       @"offline" // 离线搜索时数据存储的数据库名称
#define OFFLINE_COLUMN_FILEID    @"file_id"
#define OFFLINE_COLUMN_NAME      @"file_name"
#define OFFLINE_COLUMN_TITLE     @"file_title"
#define OFFLINE_COLUMN_TYPE      @"file_type"
#define OFFLINE_COLUMN_DESC      @"desc"
#define OFFLINE_COLUMN_TAGS      @"tags"
#define OFFLINE_COLUMN_CATEGORYID   @"category_id"
#define OFFLINE_COLUMN_CATEGORYNAME @"category_name"
#define OFFLINE_COLUMN_CREATEDATE   @"edit_time"
#define OFFLINE_COLUMN_PAGENUM   @"page_num"
#define OFFLINE_COLUMN_ZIPURL    @"zip_url"
#define OFFLINE_COLUMN_ZIPSIZE   @"zip_size"

#define DB_COLUMN_CREATED      @"created_at"
#define DB_COLUMN_UPDATED      @"updated_at"


// 公告通知
#define NOTIFICATION_URL_PATH     @"/api/News_api.php"
#define NOTIFICATION_OCCUR_DATE   @"occur_date" // 通告与预告的区分字段
#define NOTIFICATION_TITLE_FONT   14.0f // 公告标题字体大小
#define NOTIFICATION_MSG_FONT     12.0f // 公告内容字体大小
#define NOTIFICATION_DATE_FONT    14.0f // 公告日期字体大小
// 公告API参数
#define NOTIFICATION_PARAM_DEPTID     @"did" // 部门ID
#define NOTIFICATION_PARAM_DATESTR    @"strdate" // 当前日期
// 公告API响应字段
#define NOTIFICATION_FIELD_STATUS     @"status"
#define NOTIFICATION_FIELD_COUNT      @"count"
#define NOTIFICATION_FIELD_GGDATA     @"ggdata" // 公告数据
#define NOTIFICATION_FIELD_HDDATA     @"hddata" // 预告活动
#define NOTIFICATION_FIELD_TITLE      @"Title"  // 标题
#define NOTIFICATION_FIELD_MSG        @"Msg"     // 内容
#define NOTIFICATION_FIELD_CREATEDATE @"EditTime" // 创建日期
#define NOTIFICATION_FIELD_OCCURDATE  @"OccurTime"// 发生日期（公告为空)

// app版本控件
#define VERSION_LATEST                @"latest_version"
#define VERSION_CHANGELOG             @"change_log"
#define VERSION_INSERTURL             @"insert_url"

#define ACTION_DOWNLOAD          @"download"
#define ACTION_REMOVE            @"remove"
#define ACTION_DISPLAY           @"display"
#define ACTION_ADD_TO_FAVORITE   @"add_to_favorite"

// actionLog
#define ACTIONLOG_TABLE_NAME          @"action_logs"
#define ACTIONLOG_COLUMN_UID          @"user_id"
#define ACTIONLOG_COLUMN_FUNNAME      @"function_name"
#define ACTIONLOG_COLUMN_ACTNAME      @"action_name"
#define ACTIONLOG_COLUMN_ACTRET       @"action_return"
#define ACTIONLOG_COLUMN_ACTOBJ       @"action_object"
#define LOCAL_COLUMN_SLIDE_ID         @"local_slide_id"
#define LOCAL_COLUMN_SLIDE_TYPE       @"local_slide_type"
#define LOCAL_COLUMN_ACTION           @"local_action"
#define ACTIONLOG_COLUMN_ISSYNC       @"is_synced"
#define ACTIONLOG_COLUMN_DELETED      @"is_deleted"

#define ACTIONLOG_FIELD_UID           @"UserId"
#define ACTIONLOG_FIELD_FUNNAME       @"FunctionName"
#define ACTIONLOG_FIELD_ACTNAME       @"ActionName"
#define ACTIONLOG_FIELD_ACTTIME       @"ActionTime"
#define ACTIONLOG_FIELD_ACTRET        @"ActionReturn"
#define ACTIONLOG_FIELD_ACTOBJ        @"ActionObject"

#define COURSE_DIRNAME                @"CoursePacages"
#define COURSE_PACKAGES_URL_PATH      @"/api/CoursePackets_Api.php"
#define COURSE_PACKAGES_PARAMS_UID    @"uid"
#define COURSE_PACKAGES_FIELD_DATA    @"cpdata"
#define COURSE_PACKAGES_FIELD_ID      @"Id"
#define COURSE_PACKAGES_FIELD_NAME    @"Name"
#define COURSE_PACKAGES_FIELD_DESC    @"Desc"
#define COURSE_PACKAGES_FIELD_AVTIME  @"AvailableTime"

#define COURSE_PACKAGE_CONTENT_URL_PATH   @"/api/CPOne_Api.php"
#define COURSE_PACKAGE_CONTENT_PARAMS_PID @"cpid"
// 课程包内容
#define COURSE_PACKAGES_FIELD_PACKAGES  @"CoursewarePacketList"
#define COURSE_PACKAGES_FIELD_COURSES   @"CoursewareList"
#define COURSE_PACKAGES_FIELD_QUESTIONS @"QuestionnaireList"
#define COURSE_PACKAGES_FIELD_EXAMS     @"ExamList"
// 课件包内容
#define COURSE_WRAP_FIELD_NAME  @"PPTName"
#define COURSE_WRAP_FIELD_DESC  @"PPTDesc"
#define COURSE_WRAP_FIELD_LIST  @"PPTList"

// 课程包内容
#define COURSE_DOWNLOAD_URL_PATH      @"/api/CoursewaresDown_Api.php"
#define COURSE_DOWNLOAD_PARAMS_CID    @"cid"
#define COURSE_DOWNLOAD_PARAMS_EXT    @"es"

#define PGY_APP_ID @"9d8870e80c74ae536ac2039eab8a3d19"

#endif
