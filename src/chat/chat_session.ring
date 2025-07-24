Load "stdlibcore.ring"
Load "../core/transformer.ring"
Load "../utils/tokenizer.ring"
Load "../utils/logger.ring"
Load "../utils/globals.ring"

# المتغيرات العامة
oSession
func main
    # اختبار بسيط للتأكد من عمل النظام
    oSession = new ChatSession()
    
    See "اختبار نظام المحادثة..." + nl
    
    # إضافة رسالة باللغة العربية
    cResult = oSession.translate("مرحباً بك", "ar", "en")
    See "الترجمة: " + cResult + nl
    
    # إضافة رسالة باللغة الإنجليزية
    cResult = oSession.translate("How are you?", "en", "ar")
    See "الترجمة: " + cResult + nl
    
    See "اكتمل الاختبار!" + nl

# تشغيل البرنامج عند استدعائه مباشرة
if sysargv[2] = filename()
    main()
ok

# إدارة جلسة المحادثة
Class ChatSession
    # المكونات الأساسية
    oTransformer
    oTokenizer
    oLogger
    aHistory
    nContextSize = g_nContextSize  # عدد الرسائل السابقة للسياق
    
    func init
        oLogger = new Logger("chat_session")
        oTokenizer = new ArabicTokenizer()
        aHistory = []
        
        # تهيئة النموذج
        oConfig = new TransformerConfig()
        oConfig.contextual = true  # تفعيل دعم السياق
        oTransformer = new Transformer(oConfig)
        
    func addMessage(cText, cLang, cRole)
        oMessage = new ChatMessage{
            text: cText,
            lang: cLang,  # "ar" أو "en"
            role: cRole,  # "user" أو "assistant"
            timestamp: TimeList()[5]
        }
        add(aHistory, oMessage)
        
    func getContext
        nStart = max(1, len(aHistory) - nContextSize)
        return slice(aHistory, nStart, len(aHistory))
        
    func translate(cText, cFromLang, cToLang)
        # إضافة النص للسياق
        addMessage(cText, cFromLang, "user")
        
        try
            # تحضير السياق
            cContext = prepareContext()
            
            # ترميز النص مع السياق
            aTokens = oTokenizer.tokenize(cContext + " " + cText, cFromLang = "ar")
            
            # الترجمة
            aTranslated = oTransformer.translate(aTokens)
            cTranslation = oTokenizer.detokenize(aTranslated)
            
            # إضافة الترجمة للسياق
            addMessage(cTranslation, cToLang, "assistant")
            
            return cTranslation
            
        catch
            oLogger.error("خطأ في الترجمة: " + cCatchError)
            return "عذراً، حدث خطأ في الترجمة"
        end
        
    private
        func prepareContext
            aContext = getContext()
            cResult = ""
            
            for oMessage in aContext
                if oMessage.role = "user"
                    cResult += "[المستخدم] "
                else
                    cResult += "[المساعد] "
                ok
                cResult += oMessage.text + " "
            next
            
            return cResult
            
        func max(a, b)
            if a > b return a else return b ok
            
class ChatMessage
    text
    lang
    role
    timestamp

