Load "stdlibcore.ring"
Load "chat_session.ring"
Load "../utils/logger.ring"
Load "../utils/globals.ring"

# المتغيرات العامة
oChat
oLogger
func main
    oChat = new ChatInterface()
    oLogger = new Logger("chat_interface")
    
    # تحليل وسائط سطر الأوامر
    aArgs = sysargv
    
    if len(aArgs) = 1
        # بدء محادثة جديدة
        oChat.startChat()
        return
    ok
    
    if len(aArgs) = 3
        processCommandArgs(aArgs)
        return
    ok
    
    showUsage()

func processCommandArgs(aArgs)
    switch aArgs[2]
        on "--load"
            if oChat.loadChat(aArgs[3])
                See "تم تحميل المحادثة السابقة" + nl
                oChat.startChat()
            else
                See "فشل في تحميل المحادثة" + nl
            ok
            
        on "--save"
            if oChat.startChat()
                if oChat.saveChat(aArgs[3])
                    See "تم حفظ المحادثة" + nl
                else
                    See "فشل في حفظ المحادثة" + nl
                ok
            ok
    off

func showUsage
    See "الاستخدام:" + nl
    See "محادثة جديدة: ring chat_interface.ring" + nl
    See "تحميل محادثة: ring chat_interface.ring --load chat.txt" + nl
    See "حفظ المحادثة: ring chat_interface.ring --save chat.txt" + nl


Class ChatInterface
    # المكونات الأساسية
    oSession
    
    func init
        oSession = new ChatSession()
        
    func startChat
        See "مرحباً بك في نظام المحادثة العربية-الإنجليزية!" + nl
        See "يمكنك الكتابة بأي لغة وسيتم الترجمة تلقائياً" + nl
        See "اكتب 'خروج' أو 'exit' للخروج" + nl
        See "اكتب 'تبديل' أو 'switch' لتغيير اللغة" + nl
        See "اكتب 'مسح' أو 'clear' لمسح المحادثة" + nl + nl
        
        cCurrentLang = "ar"  # اللغة الافتراضية
        
        while true
            if cCurrentLang = "ar"
                See "[عربي] "
            else
                See "[English] "
            ok
            
            cInput = GetString()
            cInput = trim(cInput)
            
            # التحقق من الأوامر الخاصة
            switch lower(cInput)
                on "خروج" on "exit"
                    See "شكراً لاستخدام نظام المحادثة!" + nl
                    exit
                    
                on "تبديل" on "switch"
                    if cCurrentLang = "ar"
                        cCurrentLang = "en"
                        See "Switched to English" + nl
                    else
                        cCurrentLang = "ar"
                        See "تم التبديل إلى العربية" + nl
                    ok
                    loop
                    
                on "مسح" on "clear"
                    oSession = new ChatSession()
                    See "تم مسح المحادثة" + nl
                    loop
                    
                other
                    if len(cInput) > 0
                        # تحديد لغة الإدخال والهدف
                        if cCurrentLang = "ar"
                            cFromLang = "ar"
                            cToLang = "en"
                        else
                            cFromLang = "en"
                            cToLang = "ar"
                        ok
                        
                        # الترجمة
                        cTranslation = oSession.translate(cInput, cFromLang, cToLang)
                        
                        # عرض الترجمة
                        if cToLang = "ar"
                            See "[الترجمة] "
                        else
                            See "[Translation] "
                        ok
                        See cTranslation + nl + nl
                    ok
            off
        end
        
    func saveChat(cFileName)
        try
            fp = fopen(cFileName, "w")
            
            for oMessage in oSession.aHistory
                cLine = oMessage.timestamp + " [" + 
                       oMessage.role + "/" + oMessage.lang + "] " + 
                       oMessage.text + nl
                       
                fputs(fp, cLine)
            next
            
            fclose(fp)
            return true
            
        catch
            oLogger.error("خطأ في حفظ المحادثة: " + cCatchError)
            return false
        end
        
    func loadChat(cFileName)
        if not isFile(cFileName)
            return false
        ok
        
        try
            oSession = new ChatSession()
            fp = fopen(cFileName, "r")
            
            while not feof(fp)
                cLine = trim(fgets(fp))
                if len(cLine) > 0
                    # تحليل السطر وإضافته للمحادثة
                    aMatch = regex(cLine, "^(.+?) \[(.+?)\/(.+?)\] (.+)$")
                    if len(aMatch) = 5
                        oSession.addMessage(
                            aMatch[4],  # النص
                            aMatch[3],  # اللغة
                            aMatch[2]   # الدور
                        )
                    ok
                ok
            end
            
            fclose(fp)
            return true
            
        catch
            oLogger.error("خطأ في تحميل المحادثة: " + cCatchError)
            return false
        end

