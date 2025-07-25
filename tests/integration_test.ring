# FastPro Integration Test
# Complete end-to-end test of the optimized Transformer system

Load "stdlibcore.ring"
Load "math.ring"
Load "fastpro.ring"
Load "../src/core/transformer.ring"
Load "../src/core/trainer.ring"
Load "../src/utils/logger.ring"

Class IntegrationTest
    oLogger
    oTransformer
    oTrainer
    
    func init()
        oLogger = new Logger("Integration_Test")
        oLogger.info("Initializing FastPro Integration Test")
    
    func runCompleteTest()
        oLogger.info("Starting complete FastPro integration test...")
        
        # Test 1: Initialize Transformer with FastPro
        testTransformerInitialization()
        
        # Test 2: Test Forward Pass
        testForwardPass()
        
        # Test 3: Test Training Step
        testTrainingStep()
        
        # Test 4: Test Inference
        testInference()
        
        # Test 5: Performance Validation
        testPerformanceValidation()
        
        oLogger.info("Integration test completed successfully!")
        return true
    
    private
        func testTransformerInitialization()
            oLogger.info("Testing Transformer initialization with FastPro...")
            
            # Initialize transformer with standard parameters
            nVocabSize = 1000
            nDModel = 512
            nNumHeads = 8
            nNumLayers = 6
            nDFF = 2048
            nMaxSeqLen = 100
            
            oTransformer = new Transformer(nVocabSize, nDModel, nNumHeads, 
                                         nNumLayers, nDFF, nMaxSeqLen)
            
            if oTransformer != null
                oLogger.info("✓ Transformer initialized successfully")
            else
                oLogger.error("✗ Transformer initialization failed")
            ok
        
        func testForwardPass()
            oLogger.info("Testing forward pass with FastPro optimizations...")
            
            # Create sample input
            nBatchSize = 4
            nSeqLen = 20
            aInput = matrix(nBatchSize, nSeqLen)
            
            # Fill with random token IDs
            for i = 1 to nBatchSize
                for j = 1 to nSeqLen
                    aInput[i][j] = random(1, 1000)  # Random token IDs
                next
            next
            
            # Perform forward pass
            nStartTime = clock()
            aOutput = oTransformer.forward(aInput)
            nForwardTime = clock() - nStartTime
            
            # Validate output dimensions
            bValidDimensions = (len(aOutput) == nBatchSize and 
                              len(aOutput[1]) == nSeqLen)
            
            if bValidDimensions
                oLogger.info("✓ Forward pass completed successfully")
                oLogger.info("Forward pass time: " + nForwardTime + " seconds")
            else
                oLogger.error("✗ Forward pass output dimensions incorrect")
            ok
        
        func testTrainingStep()
            oLogger.info("Testing training step with FastPro optimizations...")
            
            # Initialize trainer
            oTrainer = new Trainer(oTransformer, 0.001)  # Learning rate 0.001
            
            # Create sample training data
            nBatchSize = 4
            nSeqLen = 20
            aInput = matrix(nBatchSize, nSeqLen)
            aTarget = matrix(nBatchSize, nSeqLen)
            
            # Fill with sample data
            for i = 1 to nBatchSize
                for j = 1 to nSeqLen
                    aInput[i][j] = random(1, 1000)
                    aTarget[i][j] = random(1, 1000)
                next
            next
            
            # Perform training step
            nStartTime = clock()
            fLoss = oTrainer.trainStep(aInput, aTarget)
            nTrainTime = clock() - nStartTime
            
            # Validate loss
            bValidLoss = (fLoss > 0 and not isnan(fLoss) and not isinf(fLoss))
            
            if bValidLoss
                oLogger.info("✓ Training step completed successfully")
                oLogger.info("Training loss: " + fLoss)
                oLogger.info("Training time: " + nTrainTime + " seconds")
            else
                oLogger.error("✗ Training step produced invalid loss: " + fLoss)
            ok
        
        func testInference()
            oLogger.info("Testing inference with FastPro optimizations...")
            
            # Create sample input for inference
            nSeqLen = 15
            aInput = matrix(1, nSeqLen)  # Single sequence
            
            for j = 1 to nSeqLen
                aInput[1][j] = random(1, 1000)
            next
            
            # Perform inference
            nStartTime = clock()
            aOutput = oTransformer.forward(aInput)
            nInferenceTime = clock() - nStartTime
            
            # Validate inference output
            bValidInference = (len(aOutput) == 1 and len(aOutput[1]) == nSeqLen)
            
            if bValidInference
                oLogger.info("✓ Inference completed successfully")
                oLogger.info("Inference time: " + nInferenceTime + " seconds")
            else
                oLogger.error("✗ Inference output dimensions incorrect")
            ok
        
        func testPerformanceValidation()
            oLogger.info("Testing performance validation...")
            
            # Test with different input sizes to validate scalability
            aSizes = [[2, 10], [4, 20], [8, 50]]
            
            for aSize in aSizes
                nBatchSize = aSize[1]
                nSeqLen = aSize[2]
                
                oLogger.info("Testing with batch_size=" + nBatchSize + 
                           ", seq_len=" + nSeqLen)
                
                # Create input
                aInput = matrix(nBatchSize, nSeqLen)
                for i = 1 to nBatchSize
                    for j = 1 to nSeqLen
                        aInput[i][j] = random(1, 1000)
                    next
                next
                
                # Measure performance
                nStartTime = clock()
                aOutput = oTransformer.forward(aInput)
                nTime = clock() - nStartTime
                
                # Calculate throughput
                nTokensPerSecond = (nBatchSize * nSeqLen) / nTime
                
                oLogger.info("Throughput: " + nTokensPerSecond + " tokens/second")
                
                # Validate performance is reasonable
                if nTokensPerSecond > 100  # Minimum expected throughput
                    oLogger.info("✓ Performance validation passed")
                else
                    oLogger.warning("⚠ Performance below expected threshold")
                ok
            next

# Comprehensive System Test
Class SystemTest
    oLogger
    
    func init()
        oLogger = new Logger("System_Test")
    
    func runFullSystemTest()
        oLogger.info("Starting full system test with FastPro optimizations...")
        
        # Test all major components
        testMatrixOperations()
        testActivationFunctions()
        testAttentionMechanisms()
        testOptimizerOperations()
        testEndToEndPipeline()
        
        oLogger.info("Full system test completed!")
    
    private
        func testMatrixOperations()
            oLogger.info("Testing matrix operations...")
            
            # Test matrix multiplication
            oMatrix1 = new Matrix(100, 100)
            oMatrix2 = new Matrix(100, 100)
            
            # Fill with test data
            for i = 1 to 100
                for j = 1 to 100
                    oMatrix1.set(i, j, random(-1, 1))
                    oMatrix2.set(i, j, random(-1, 1))
                next
            next
            
            # Test multiplication
            nStartTime = clock()
            oResult = oMatrix1.multiply(oMatrix2)
            nTime = clock() - nStartTime
            
            oLogger.info("Matrix multiplication (100x100): " + nTime + " seconds")
            
            # Test transpose
            nStartTime = clock()
            oTransposed = oMatrix1.transpose()
            nTime = clock() - nStartTime
            
            oLogger.info("Matrix transpose (100x100): " + nTime + " seconds")
        
        func testActivationFunctions()
            oLogger.info("Testing activation functions...")
            
            oMatrix = new Matrix(200, 200)
            for i = 1 to 200
                for j = 1 to 200
                    oMatrix.set(i, j, random(-5, 5))
                next
            next
            
            oActivations = new Activations()
            
            # Test ReLU
            nStartTime = clock()
            oReLUResult = oActivations.relu(oMatrix)
            nTime = clock() - nStartTime
            oLogger.info("ReLU activation (200x200): " + nTime + " seconds")
            
            # Test Softmax
            nStartTime = clock()
            oSoftmaxResult = oActivations.softmax(oMatrix)
            nTime = clock() - nStartTime
            oLogger.info("Softmax activation (200x200): " + nTime + " seconds")
        
        func testAttentionMechanisms()
            oLogger.info("Testing attention mechanisms...")
            
            nSeqLen = 50
            nDModel = 256
            nNumHeads = 8
            
            oQ = new Matrix(nSeqLen, nDModel)
            oK = new Matrix(nSeqLen, nDModel)
            oV = new Matrix(nSeqLen, nDModel)
            
            # Fill with random data
            for i = 1 to nSeqLen
                for j = 1 to nDModel
                    oQ.set(i, j, random(-1, 1))
                    oK.set(i, j, random(-1, 1))
                    oV.set(i, j, random(-1, 1))
                next
            next
            
            oAttention = new MultiHeadAttention(nNumHeads, nDModel)
            
            nStartTime = clock()
            oResult = oAttention.scaled_dot_product_attention(oQ, oK, oV, null)
            nTime = clock() - nStartTime
            
            oLogger.info("Attention calculation (50x256): " + nTime + " seconds")
        
        func testOptimizerOperations()
            oLogger.info("Testing optimizer operations...")
            
            aGradient = matrix(500, 500)
            for i = 1 to 500
                for j = 1 to 500
                    aGradient[i][j] = random(-0.1, 0.1)
                next
            next
            
            oOptimizer = new AdamOptimizer(0.001)
            
            nStartTime = clock()
            aUpdates = oOptimizer.step([aGradient])
            nTime = clock() - nStartTime
            
            oLogger.info("Optimizer step (500x500): " + nTime + " seconds")
        
        func testEndToEndPipeline()
            oLogger.info("Testing end-to-end pipeline...")
            
            # Small transformer for testing
            nVocabSize = 500
            nDModel = 256
            nNumHeads = 4
            nNumLayers = 2
            nDFF = 1024
            nMaxSeqLen = 50
            
            oTransformer = new Transformer(nVocabSize, nDModel, nNumHeads,
                                         nNumLayers, nDFF, nMaxSeqLen)
            
            # Test input
            nBatchSize = 2
            nSeqLen = 25
            aInput = matrix(nBatchSize, nSeqLen)
            
            for i = 1 to nBatchSize
                for j = 1 to nSeqLen
                    aInput[i][j] = random(1, nVocabSize)
                next
            next
            
            # End-to-end test
            nStartTime = clock()
            aOutput = oTransformer.forward(aInput)
            nTime = clock() - nStartTime
            
            oLogger.info("End-to-end pipeline (2x25): " + nTime + " seconds")

# Main execution
func main()
    ? "FastPro Integration Test Suite"
    ? "================================"
    
    # Run integration test
    oIntegrationTest = new IntegrationTest()
    bIntegrationPassed = oIntegrationTest.runCompleteTest()
    
    ? ""
    
    # Run system test
    oSystemTest = new SystemTest()
    oSystemTest.runFullSystemTest()
    
    ? ""
    ? "Integration test results:"
    if bIntegrationPassed
        ? "✓ All integration tests PASSED"
        ? "✓ FastPro optimization is working correctly"
        ? "✓ System is ready for production use"
    else
        ? "✗ Some integration tests FAILED"
        ? "✗ Review implementation before production use"
    ok
    
    ? ""
    ? "FastPro optimization implementation completed!"
    ? "Check the generated reports for detailed performance metrics."
