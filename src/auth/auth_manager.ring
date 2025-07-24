Load "openssllib.ring"
Load "../utils/logger.ring"

# مدير المصادقة
Class AuthManager
    # المتغيرات الأساسية
    aTokens
    oLogger
    cSecretKey
    
    func init()
        aTokens = []
        oLogger = new Logger("logs/auth.log")
        cSecretKey = "your-secret-key-here"  # يجب تغييره في الإنتاج
    
    # إنشاء توكن جديد
    func generateToken(cUsername)
        cTimestamp = string(time())
        cData = cUsername + "|" + cTimestamp
        cToken = SHA256(cData + cSecretKey)
        
        addToken(cToken, cUsername)
        return cToken
    
    # التحقق من صلاحية التوكن
    func validateToken(cToken)
        if not cToken return false ok
        
        for oToken in aTokens
            if oToken[:token] = cToken
                if isTokenExpired(oToken)
                    removeToken(cToken)
                    return false
                ok
                return true
            ok
        next
        return false
    
    # الحصول على اسم المستخدم من التوكن
    func getUsernameFromToken(cToken)
        for oToken in aTokens
            if oToken[:token] = cToken
                return oToken[:username]
            ok
        next
        return null
    
    private
        # إضافة توكن جديد
        func addToken(cToken, cUsername)
            add(aTokens, {
                :token = cToken,
                :username = cUsername,
                :created_at = time()
            })
        
        # إزالة توكن
        func removeToken(cToken)
            for x = 1 to len(aTokens)
                if aTokens[x][:token] = cToken
                    del(aTokens, x)
                    return true
                ok
            next
            return false
        
        # التحقق من انتهاء صلاحية التوكن
        func isTokenExpired(oToken)
            nTokenAge = time() - oToken[:created_at]
            return nTokenAge > 3600  # ينتهي بعد ساعة واحدة
