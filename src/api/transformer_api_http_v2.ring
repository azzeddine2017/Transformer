Load "httplib.ring"
Load "ziplib.ring"
Load "../config/system_config.ring"
Load "../core/transformer.ring"
Load "../core/data_manager.ring"
Load "../utils/logger.ring"
Load "../auth/auth_manager.ring"
Load "../web/dashboard.ring"

# تشغيل الخادم
func main
    oAPI = new TransformerAPI
    oAPI.start()

# واجهة برمجة التطبيقات الموحدة للمحول مع دعم المصادقة والضغط
Class TransformerAPI from TransformerAPI
    # إضافة مدير المصادقة
    oAuthManager
    
    func init
        super.init()
        oAuthManager = new AuthManager
        
        # إضافة مسارات المصادقة وواجهة المستخدم
        setupAuthRoutes()
    
    func setupAuthRoutes
        # مسارات المصادقة
        oServer.route(:Post, "/auth/login", :handleLogin)
        oServer.route(:Post, "/auth/logout", :handleLogout)
        
        # واجهة المستخدم
        oServer.route(:Get, "/", :handleDashboard)
        
        # مشاركة المجلد العام
        oServer.shareFolder("public")
    
    # التحقق من المصادقة
    func checkAuth
        cToken = oServer.getHeader("Authorization")
        if not oAuthManager.validateToken(cToken)
            sendError("غير مصرح به", 401)
            return false
        ok
        return true
    
    # معالجة طلبات المصادقة
    func handleLogin
        try
            oParams = parseRequest()
            
            # في الإنتاج، يجب التحقق من قاعدة البيانات
            if oParams["username"] = "admin" and oParams["password"] = "admin"
                cToken = oAuthManager.generateToken(oParams["username"])
                return sendSuccess("تم تسجيل الدخول بنجاح", {"token": cToken})
            ok
            
            return sendError("اسم المستخدم أو كلمة المرور غير صحيحة")
        catch
            return sendError("خطأ في تسجيل الدخول: " + cCatchError)
        done
    
    func handleLogout
        try
            if not checkAuth() return ok
            
            cToken = oServer.getHeader("Authorization")
            oAuthManager.removeToken(cToken)
            return sendSuccess("تم تسجيل الخروج بنجاح")
        catch
            return sendError("خطأ في تسجيل الخروج: " + cCatchError)
        done
    
    # واجهة المستخدم
    func handleDashboard
        oDashboard = new Dashboard
        oServer.setHTMLPage(oDashboard.getPage())
    
    # تجاوز معالجات الطلبات لإضافة المصادقة وضغط البيانات
    func handleTraining
        if not checkAuth() return ok
        super.handleTraining()
    
    func handlePrediction
        if not checkAuth() return ok
        super.handlePrediction()
    
    func handleDataUpload
        if not checkAuth() return ok
        
        try
            oParams = parseRequest()
            if not oParams["data"]
                return sendError("لم يتم تحديد البيانات")
            ok
            
            # ضغط البيانات
            cCompressed = compress(oParams["data"])
            
            cPath = oConfig.cCachePath + "upload_" + random(1000000) + ".zip"
            write(cPath, cCompressed)
            
            return sendSuccess("تم رفع البيانات بنجاح", {"path": cPath})
        catch
            return sendError("خطأ في رفع البيانات: " + cCatchError)
        done
    
    # دوال مساعدة إضافية
    private
        func compress(cData)
            oZip = new ZipLib
            return oZip.compress(cData)
        
        func decompress(cData)
            oZip = new ZipLib
            return oZip.decompress(cData)
