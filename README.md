# Swift Package Manager for ONNX Runtime (ANE Fork)

A fork of the [official ONNX Runtime Swift Package](https://github.com/microsoft/onnxruntime-swift-package-manager) with added support for Apple's `MLComputeUnits` configuration, enabling CPU+Neural Engine execution (excluding GPU) for iOS background audio processing.

## Fork Changes

This fork adds the `computeUnits` property to `ORTCoreMLExecutionProviderOptions`, allowing you to specify which compute units CoreML should use:

```swift
let options = ORTCoreMLExecutionProviderOptions()
options.computeUnits = .cpuAndNeuralEngine  // Use CPU + ANE, exclude GPU
try sessionOptions.appendCoreMLExecutionProvider(with: options)
```

### Available Options

| Value | Description |
|-------|-------------|
| `.all` | Use all compute units (default) |
| `.cpuOnly` | CPU only |
| `.cpuAndGPU` | CPU + GPU (excludes Neural Engine) |
| `.cpuAndNeuralEngine` | CPU + Neural Engine (excludes GPU) |

### Why This Fork?

iOS blocks GPU access for background apps. When using ONNX Runtime with CoreML in background audio processing (wake word detection, VAD), the default configuration causes `IOGPUMetalError: Insufficient Permission` errors.

Using `.cpuAndNeuralEngine` enables power-efficient Neural Engine inference while avoiding GPU permission issues in background mode.

## Usage

```swift
dependencies: [
    .package(url: "https://github.com/matthewdrulias/onnxruntime-swift-ane", from: "1.20.0"),
]
```

## Original README

A light-weight repository for providing [Swift Package Manager (SPM)](https://www.swift.org/package-manager/) support for [ONNXRuntime](https://github.com/microsoft/onnxruntime). The ONNX Runtime native package is included as a binary dependency of the SPM package.

SPM is the alternative to CocoaPods when desired platform to consume is mobile iOS.

## Note

The `objectivec/` directory is copied from the [ORT repo](https://github.com/microsoft/onnxruntime/tree/main/objectivec) and it's expected to match. It will be updated periodically/before release to merge new changes.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
