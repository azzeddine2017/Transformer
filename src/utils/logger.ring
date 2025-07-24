Load "stdlibcore.ring"


# نظام تسجيل الأخطاء والأحداث
Class Logger {
    # مستويات التسجيل
    cLevelDebug = "DEBUG"
    cLevelInfo = "INFO"
    cLevelWarning = "WARNING"
    cLevelError = "ERROR"
    
    # إعدادات التسجيل
    cLogFile = "logs/transformer.log"
    bConsoleOutput = true
    bFileOutput = true
    cCurrentLevel = "INFO"
    
    func init(cLogPath, cLevel) {
        if len(cLogPath) > 0 { cLogFile = cLogPath }
        if len(cLevel) > 0 { cCurrentLevel = cLevel }
        
        # إنشاء مجلد السجلات إذا لم يكن موجوداً
        cDir = justpath(cLogFile)
        if not direxists(cDir) {
            system("mkdir " + cDir)
        }
    }
    
    func formatMessage(cLevel, cMessage) {
        cTimestamp = TimeList()[5]
        return "[" + cTimestamp + "] [" + cLevel + "] " + cMessage
    }
    
    func writeToFile(cMessage) {
        if bFileOutput {
            write(cLogFile, cMessage + nl, "a+")
        }
    }
    
    func writeToConsole(cMessage) {
        if bConsoleOutput {
            ? cMessage
        }
    }
    
    func log(cLevel, cMessage) {
        cFormattedMsg = formatMessage(cLevel, cMessage)
        writeToFile(cFormattedMsg)
        writeToConsole(cFormattedMsg)
    }
    
    # وظائف التسجيل حسب المستوى
    func debug(cMessage) {
        if isLevelEnabled(cLevelDebug) {
            log(cLevelDebug, cMessage)
        }
    }
    
    func info(cMessage) {
        if isLevelEnabled(cLevelInfo) {
            log(cLevelInfo, cMessage)
        }
    }
    
    func warning(cMessage) {
        if isLevelEnabled(cLevelWarning) {
            log(cLevelWarning, cMessage)
        }
    }
    
    func error(cMessage) {
        if isLevelEnabled(cLevelError) {
            log(cLevelError, cMessage)
        }
    }
    
    private
        # التحقق من تفعيل مستوى التسجيل
        func isLevelEnabled(cLevel) {
            aLevels = [cLevelDebug, cLevelInfo, cLevelWarning, cLevelError]
            nCurrentIndex = find(aLevels, cCurrentLevel)
            nTargetIndex = find(aLevels, cLevel)
            return nTargetIndex >= nCurrentIndex
        }
}
