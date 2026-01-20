// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "ort_coreml_execution_provider.h"

#import "cxx_api.h"
#import "error_utils.h"
#import "ort_session_internal.h"

#include <unordered_map>
#include <string>

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
    // Check if using new computeUnits API or legacy flags
    // Use provider options API when computeUnits is explicitly set to non-default,
    // or when not using legacy useCPUOnly/useCPUAndGPU properties
    BOOL useLegacyFlags = (options.computeUnits == ORTCoreMLComputeUnitsAll) &&
                          (options.useCPUOnly || options.useCPUAndGPU ||
                           (!options.useCPUOnly && !options.useCPUAndGPU));

    // If computeUnits is set to a specific value, always use provider options API
    if (options.computeUnits != ORTCoreMLComputeUnitsAll) {
      useLegacyFlags = NO;
    }

    // Also use legacy flags if onlyEnableForDevicesWithANE is set (not available in provider options)
    if (options.onlyEnableForDevicesWithANE) {
      useLegacyFlags = YES;
    }

    if (!useLegacyFlags && options.computeUnits != ORTCoreMLComputeUnitsAll) {
      // Use provider options API for MLComputeUnits support
      std::unordered_map<std::string, std::string> provider_options;

      // Convert compute units enum to string
      switch (options.computeUnits) {
        case ORTCoreMLComputeUnitsCPUOnly:
          provider_options["MLComputeUnits"] = "CPU_ONLY";
          break;
        case ORTCoreMLComputeUnitsCPUAndGPU:
          provider_options["MLComputeUnits"] = "CPU_AND_GPU";
          break;
        case ORTCoreMLComputeUnitsCPUAndNeuralEngine:
          provider_options["MLComputeUnits"] = "CPU_AND_NE";
          break;
        default:
          provider_options["MLComputeUnits"] = "ALL";
          break;
      }

      // Map boolean options to provider options
      if (options.enableOnSubgraphs) {
        provider_options["EnableOnSubgraphs"] = "1";
      }

      if (options.onlyAllowStaticInputShapes) {
        provider_options["RequireStaticInputShapes"] = "1";
      }

      if (options.createMLProgram) {
        provider_options["ModelFormat"] = "MLProgram";
      }

      // Note: onlyEnableForDevicesWithANE is not available via provider options
      // If that option is needed, the legacy flags path is used instead

      [self CXXAPIOrtSessionOptions].AppendExecutionProvider("CoreML", provider_options);
      return YES;
    } else {
      // Use legacy flags API (preserves all existing behavior including onlyEnableForDevicesWithANE)
      const uint32_t flags =
          (options.useCPUOnly ? COREML_FLAG_USE_CPU_ONLY : 0) |
          (options.useCPUAndGPU ? COREML_FLAG_USE_CPU_AND_GPU : 0) |
          (options.enableOnSubgraphs ? COREML_FLAG_ENABLE_ON_SUBGRAPH : 0) |
          (options.onlyEnableForDevicesWithANE ? COREML_FLAG_ONLY_ENABLE_DEVICE_WITH_ANE : 0) |
          (options.onlyAllowStaticInputShapes ? COREML_FLAG_ONLY_ALLOW_STATIC_INPUT_SHAPES : 0) |
          (options.createMLProgram ? COREML_FLAG_CREATE_MLPROGRAM : 0);

      Ort::ThrowOnError(OrtSessionOptionsAppendExecutionProvider_CoreML(
          [self CXXAPIOrtSessionOptions], flags));
      return YES;
    }
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
