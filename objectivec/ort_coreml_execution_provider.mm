// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "ort_coreml_execution_provider.h"

#import "cxx_api.h"
#import "error_utils.h"
#import "ort_session_internal.h"

NS_ASSUME_NONNULL_BEGIN

BOOL ORTIsCoreMLExecutionProviderAvailable() {
  return ORT_OBJC_API_COREML_EP_AVAILABLE ? YES : NO;
}

@implementation ORTCoreMLExecutionProviderOptions

- (instancetype)init {
  if (self = [super init]) {
    _computeUnits = ORTCoreMLComputeUnitsAll;
  }
  return self;
}

@end

@implementation ORTSessionOptions (ORTSessionOptionsCoreMLEP)

- (BOOL)appendCoreMLExecutionProviderWithOptions:(ORTCoreMLExecutionProviderOptions*)options
                                           error:(NSError**)error {
#if ORT_OBJC_API_COREML_EP_AVAILABLE
  try {
    // Build flags from computeUnits enum and boolean options
    // Note: The pre-built ONNX Runtime binary only supports the flags-based API.
    // The provider options API (which would support MLComputeUnits.cpuAndNeuralEngine)
    // is not available because CoreML isn't registered for the generic provider path.
    uint32_t flags = 0;

    // Map computeUnits enum to available flags
    switch (options.computeUnits) {
      case ORTCoreMLComputeUnitsCPUOnly:
        flags |= COREML_FLAG_USE_CPU_ONLY;
        break;
      case ORTCoreMLComputeUnitsCPUAndGPU:
        flags |= COREML_FLAG_USE_CPU_AND_GPU;
        break;
      case ORTCoreMLComputeUnitsCPUAndNeuralEngine:
        // Unfortunately, there's no flag for CPU+ANE (excluding GPU).
        // The ONNX Runtime flags API doesn't support this combination.
        // Fall through to use ALL compute units as the closest option.
        // To truly exclude GPU, you would need to build ORT from source.
        break;
      case ORTCoreMLComputeUnitsAll:
      default:
        // No flag needed - ALL is the default
        break;
    }

    // Support legacy boolean properties (deprecated but still functional)
    if (options.useCPUOnly) {
      flags |= COREML_FLAG_USE_CPU_ONLY;
    }
    if (options.useCPUAndGPU) {
      flags |= COREML_FLAG_USE_CPU_AND_GPU;
    }

    // Add other boolean flags
    flags |= (options.enableOnSubgraphs ? COREML_FLAG_ENABLE_ON_SUBGRAPH : 0);
    flags |= (options.onlyEnableForDevicesWithANE ? COREML_FLAG_ONLY_ENABLE_DEVICE_WITH_ANE : 0);
    flags |= (options.onlyAllowStaticInputShapes ? COREML_FLAG_ONLY_ALLOW_STATIC_INPUT_SHAPES : 0);
    flags |= (options.createMLProgram ? COREML_FLAG_CREATE_MLPROGRAM : 0);

    Ort::ThrowOnError(OrtSessionOptionsAppendExecutionProvider_CoreML(
        [self CXXAPIOrtSessionOptions], flags));
    return YES;
  }
  ORT_OBJC_API_IMPL_CATCH_RETURNING_BOOL(error);
#else  // !ORT_OBJC_API_COREML_EP_AVAILABLE
  static_cast<void>(options);
  ORTSaveCodeAndDescriptionToError(ORT_FAIL, "CoreML execution provider is not enabled.", error);
  return NO;
#endif
}

@end

NS_ASSUME_NONNULL_END
