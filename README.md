# windowsgazebo

Support for running Gazebo on Windows.

## Prerequisites

- Windows 10 or Windows 11 (64-bit)
- [Visual Studio 2019 or 2022](https://visualstudio.microsoft.com/) with C++ build tools
- [CMake 3.22+](https://cmake.org/download/)
- [Git for Windows](https://gitforwindows.org/)

## Installation

### Using vcpkg (Recommended)

1. Install [vcpkg](https://github.com/microsoft/vcpkg):
   ```cmd
   git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
   C:\vcpkg\bootstrap-vcpkg.bat
   ```

2. Install Gazebo dependencies:
   ```cmd
   C:\vcpkg\vcpkg install gz-sim --triplet x64-windows
   ```

3. Set up environment variables:
   ```cmd
   set CMAKE_PREFIX_PATH=C:\vcpkg\installed\x64-windows
   set GZ_VERSION=garden
   ```

### Manual Build

1. Clone this repository:
   ```cmd
   git clone https://github.com/arjun187456/windowsgazebo.git
   cd windowsgazebo
   ```

2. Configure with CMake:
   ```cmd
   cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
   ```

3. Build:
   ```cmd
   cmake --build build --config Release
   ```

## Running Gazebo on Windows

After installation, launch Gazebo from the command prompt:

```cmd
gz sim
```

To run a specific world file:

```cmd
gz sim shapes.sdf
```

## Troubleshooting

### Missing DLLs
If you encounter missing DLL errors, ensure that the vcpkg bin directory is on your `PATH`:
```cmd
set PATH=C:\vcpkg\installed\x64-windows\bin;%PATH%
```

### Firewall Warnings
Gazebo uses network sockets for inter-process communication. Allow `gz.exe` through the Windows Firewall when prompted.

### Display Issues
Ensure your GPU drivers are up to date. Gazebo requires OpenGL 3.3 or higher.

## Contributing

Contributions to improve Windows support are welcome. Please open an issue or pull request.

## License

This project follows the [Apache License 2.0](LICENSE).
