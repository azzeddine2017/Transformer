اكمل
# نظام تدريب نموذج المحول
Load "stdlibcore.ring"
Load "matrix.ring"
Load "fastpro.ring"
Load "transformer.ring"
Load "optimizer.ring"
Load "evaluator.ring"
Load "logger.ring"
Load "config.ring"

# تشغيل التدريب
func main
    try
        oTrainer = new TransformerTrainer(new Config())
        oTrainer.train()
    catch
        See "حدث خطأ أثناء التدريب: " + cCatchError + nl
    end


Class TransformerTrainer {
    # المكونات الرئيسية
    oTransformer
    oOptimizer
    oEvaluator
    oLogger
    oConfig
    
    # متغيرات التدريب
    nCurrentEpoch = 0
    nGlobalStep = 0
    aTrainingLoss = []
    aValidationLoss = []
    aBestMetrics = []
    
    func init(oConfig){
        # تهيئة المكونات
        self.oConfig = oConfig
        oTransformer = new Transformer(oConfig)
        oOptimizer = new AdamOptimizer(oConfig.fLearningRate)
        oEvaluator = new TranslationEvaluator()
        oLogger = new Logger("trainer")
    }   
    func train(){
        oLogger.info("بدء التدريب...")
        
        # تحميل البيانات
        cDataPath = "data/ar_en_parallel.txt"
        [aSourceTexts, aTargetTexts] = loadDataset(cDataPath)
        
        See "تم تحميل " + len(aSourceTexts) + " جملة للتدريب" + nl
        
        # تقسيم البيانات إلى تدريب وتحقق
        nTrainSize = floor(len(aSourceTexts) * 0.8)
        aTrainSrc = slice(aSourceTexts, 1, nTrainSize)
        aTrainTgt = slice(aTargetTexts, 1, nTrainSize)
        aValidSrc = slice(aSourceTexts, nTrainSize+1)
        aValidTgt = slice(aTargetTexts, nTrainSize+1)
        
        See "تم تحميل " + len(aTrainSrc) + " جملة للتدريب و " + 
            len(aValidSrc) + " جملة للتحقق" + nl
        
        # حلقة التدريب الرئيسية
        for epoch = 1 to oConfig.nEpochs
            nCurrentEpoch = epoch
            
            # تدريب على مجموعة التدريب
            fTrainLoss = trainEpoch(aTrainSrc, aTrainTgt)
            Add(aTrainingLoss, fTrainLoss)
            
            # تقييم على مجموعة التحقق
            fValidLoss = evaluate(aValidSrc, aValidTgt)
            Add(aValidationLoss, fValidLoss)
            
            # حفظ أفضل نموذج
            if fValidLoss < aBestMetrics[1]
                aBestMetrics[1] = fValidLoss
                saveModel()
            ok
            
            # طباعة إحصائيات الدورة
            printEpochStats(epoch, fTrainLoss, fValidLoss)
        next
        
        oLogger.info("اكتمل التدريب!")
    }   
    private

    func loadDataset(cPath){
        if not isFile(cPath)
            throw("ملف البيانات غير موجود: " + cPath)
        ok
        
        aSourceTexts = []
        aTargetTexts = []
        
        oFile = fopen(cPath, "r")
        while not feof(oFile)
            cLine = trim(fgets(oFile))
            if len(cLine) > 0
                aFields = split(cLine, "\t")
                if len(aFields) >= 2
                    Add(aSourceTexts, aFields[1])
                    Add(aTargetTexts, aFields[2])
                ok
            ok
        end
        fclose(oFile)
        
        return [aSourceTexts, aTargetTexts]
    }
    func trainEpoch(aSourceTexts, aTargetTexts){
        fTotalLoss = 0
        nSamples = len(aSourceTexts)
        nBatches = ceil(nSamples / oConfig.nBatchSize)
        
        # خلط البيانات
        aIndices = list(1:nSamples)
        aIndices = shuffle(aIndices)
        
        for batch = 1 to nBatches
            # تحضير الدفعة
            [aSourceBatch, aTargetBatch] = getBatch(aSourceTexts, aTargetTexts, 
                                                    aIndices, batch)
            
            # تدريب الدفعة
            fBatchLoss = trainStep(aSourceBatch, aTargetBatch)
            fTotalLoss += fBatchLoss
            
            # طباعة التقدم
            if batch % 10 = 0
                See "\rالدورة " + nCurrentEpoch + 
                    ", الدفعة " + batch + "/" + nBatches +
                    ", الخسارة: " + (fTotalLoss/batch)
            ok
        next
        
        return fTotalLoss / nBatches
    }       
    func trainStep(aSourceBatch, aTargetBatch){
        # استخراج المدخلات والمخرجات المتوقعة
        aInput = aSourceBatch
        aTarget = aTargetBatch
        
        # الخطوة الأمامية
        aOutput = oTransformer.forward(aInput)
        
        # حساب الخسارة
        fLoss = calculateLoss(aOutput, aTarget)
        
        # حساب التدرجات
        aGradients = calculateGradients(fLoss)
        
        # تحديث المعلمات
        aGradients = oOptimizer.step(aGradients)
        updateParameters(aGradients)
        
        return fLoss
    }   
    func evaluate(aSourceTexts, aTargetTexts){
        fTotalLoss = 0
        nSamples = len(aSourceTexts)
        
        for i = 1 to nSamples
            cPred = oTransformer.translate(aSourceTexts[i])
            fLoss = computeBLEU(cPred, aTargetTexts[i])
            fTotalLoss += fLoss
        next
        
        return fTotalLoss / nSamples
    }   
    func getBatch(aSourceTexts, aTargetTexts, aIndices, nBatch){
        nStart = (nBatch-1) * oConfig.nBatchSize + 1
        nEnd = min(nStart + oConfig.nBatchSize - 1, len(aIndices))
        
        aSourceBatch = []
        aTargetBatch = []
        
        for i = nStart to nEnd
            idx = aIndices[i]
            Add(aSourceBatch, aSourceTexts[idx])
            Add(aTargetBatch, aTargetTexts[idx])
        next
        
        return [aSourceBatch, aTargetBatch]
    }  
    func calculateLoss(aOutput, aTarget){
        # حساب خسارة الإنتروبيا المتقاطعة - FastPro Optimized
        # Add small epsilon to prevent log(0)
        aOutputSafe = updateList(aOutput, :add, :matrix, updateList(aOutput, :fill, :matrix, 1e-10))

        # Calculate log of output
        aLogOutput = updateList(aOutputSafe, :log, :matrix)

        # Element-wise multiplication with target
        aProduct = updateList(aTarget, :mul, :matrix, aLogOutput)

        # Sum all elements and negate
        fLoss = -updateList(aProduct, :allsum, :matrix)

        return fLoss / len(aOutput)
    }
    func calculateGradients(fLoss){
        # حساب التدرجات باستخدام الانتشار الخلفي
        return oTransformer.backward(fLoss)
    }  
    func updateParameters(aGradients){
        # تحديث معلمات النموذج
        oTransformer.updateParameters(aGradients)
    }  
    func computeBLEU(cHyp, cRef){
        # حساب معيار BLEU للتقييم
        aHypWords = split(cHyp)
        aRefWords = split(cRef)
        
        nMatches = 0
        for word in aHypWords
            if find(aRefWords, word) > 0
                nMatches++
            ok
        next
        
        fPrecision = nMatches / len(aHypWords)
        fRecall = nMatches / len(aRefWords)
        
        if fPrecision = 0 or fRecall = 0
            return 0
        ok
        
        return 2 * (fPrecision * fRecall) / (fPrecision + fRecall)
    }   
    func saveModel(){
        cPath = oConfig.cModelDir + "model_" + nCurrentEpoch + ".bin"
        oTransformer.saveModel(cPath)
        oLogger.info("تم حفظ النموذج في: " + cPath)
    }  
    func printEpochStats(nEpoch, fTrainLoss, fValidLoss){
        See nl + "الدورة " + nEpoch + "/" + oConfig.nEpochs + nl
        See "خسارة التدريب: " + fTrainLoss + nl
        See "خسارة التحقق: " + fValidLoss + nl
        See "أفضل خسارة: " + aBestMetrics[1] + nl + nl
    }
}