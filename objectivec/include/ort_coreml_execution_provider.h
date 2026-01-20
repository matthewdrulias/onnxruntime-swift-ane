// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

#import "ort_session.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Gets whether the CoreML execution provider is available.
 */
BOOL ORTIsCoreMLExecutionProviderAvailable(void);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * MLComputeUnits options for CoreML execution provider.
 * Maps to Apple's MLComputeUnits enum.
 */
typedef NS_ENUM(NSInteger, ORTCoreMLComputeUnits) {
    ORTCoreMLComputeUnitsAll = 0,              // Use all available compute units (default)
    ORTCoreMLComputeUnitsCPUOnly,              // Use CPU only
    ORTCoreMLComputeUnitsCPUAndGPU,            // Use CPU and GPU (excludes ANE)
    ORTCoreMLComputeUnitsCPUAndNeuralEngine,   // Use CPU and Neural Engine (excludes GPU)
};

/**
 * Options for configuring the CoreML execution provider.
 */
@interface ORTCoreMLExecutionProviderOptions : NSObject

/**
 * Which compute units to use for CoreML execution.
 * Defaults to ORTCoreMLComputeUnitsAll.
 *
 * Use ORTCoreMLComputeUnitsCPUAndNeuralEngine to enable background execution
 * (GPU is not available in background mode on iOS).
 */
@property ORTCoreMLComputeUnits computeUnits;

/**
 * Whether the CoreML execution provider should run on CPU only.
 * @deprecated Use computeUnits = ORTCoreMLComputeUnitsCPUOnly instead.
 */
@property BOOL useCPUOnly;
/**
 * exclude ANE in CoreML.
 * @deprecated Use computeUnits = ORTCoreMLComputeUnitsCPUAndGPU instead.
 */
@property BOOL useCPUAndGPU;
/**
 * Whether the CoreML execution provider is enabled on subgraphs.
 */
@property BOOL enableOnSubgraphs;

/**
 * Whether the CoreML execution provider is only enabled for devices with Apple
 * Neural Engine (ANE).
 */
@property BOOL onlyEnableForDevicesWithANE;

/**
 * Only allow CoreML EP to take nodes with inputs with static shapes. By default it will also allow inputs with
 * dynamic shapes. However, the performance may be negatively impacted if inputs have dynamic shapes.
 */
@property BOOL onlyAllowStaticInputShapes;

/**
 * Create an MLProgram. By default it will create a NeuralNetwork model. Requires Core ML 5 or later.
 */
@property BOOL createMLProgram;

@end

@interface ORTSessionOptions (ORTSessionOptionsCoreMLEP)

/**
 * Enables the CoreML execution provider in the session configuration options.
 * It is appended to the execution provider list which is ordered by
 * decreasing priority.
 *
 * @param options The CoreML execution provider configuration options.
 * @param error Optional error information set if an error occurs.
 * @return Whether the provider was enabled successfully.
 */
- (BOOL)appendCoreMLExecutionProviderWithOptions:(ORTCoreMLExecutionProviderOptions*)options
                                           error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
