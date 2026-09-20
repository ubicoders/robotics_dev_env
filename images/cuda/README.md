# CUDA images: GPU compatibility

Current pins (`.env`): CUDA 12.8.1, ZED SDK 5.0.5, which bundles TensorRT 10.9.

| GPU generation | Compute capability | CUDA 12.8 images | ZED SDK 5.x camera and classic depth | ZED SDK 5.x AI (NEURAL depth, object detection, body tracking) | CUDA 13 |
|---|---|---|---|---|---|
| Pascal (GTX 10 series, for example GTX 1080 Ti) | 6.1 | Yes | Yes | No | No |
| Volta (Titan V) | 7.0 | Yes | Yes | No | No |
| Turing (GTX 16, RTX 20 series) | 7.5 | Yes | Yes | Yes | Yes |
| Ampere (RTX 30 series) | 8.6 | Yes | Yes | Yes | Yes |
| Ada (RTX 40 series) | 8.9 | Yes | Yes | Yes | Yes |
| Blackwell (RTX 50 series) | 12.0 | Yes, needs CUDA 12.8 or newer | Yes | Yes | Yes |

- ZED AI features run on TensorRT. TensorRT 10 requires compute capability 7.5 or higher.
- CUDA 13 requires compute capability 7.5 or higher. CUDA 12.x is the last line that supports Pascal and Volta.
- CUDA 12.8 is the only version that covers both Pascal and Blackwell, which is why the images stay on it.
- For ZED SDK 5.5, use the Ubuntu 24, CUDA 12, TensorRT 10 installer.
- Building the images needs no GPU. The limits above apply when a container runs.
- Verified on 2026-09-20: on a GTX 1080 Ti, the CUDA 12.8 image runs, and NEURAL model optimization stops without producing an engine.
