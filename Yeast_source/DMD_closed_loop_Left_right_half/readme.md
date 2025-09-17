# Cell Area Control System

A PID-based control system for managing cell populations using light control. The system calculates cell areas from mask images and generates light control patterns for left and right halves independently.

## Features

- **Mask Image Processing**: Reads 2048x2048 TIF mask images and calculates non-zero pixels for cell area measurement
- **Dual PID Control**: Independent PID controllers for left and right halves with customizable setpoints
- **Light Pattern Generation**: Converts controller outputs to 2048x2048 images with pixel values 0-255
- **MATLAB Integration**: Easy-to-use MATLAB interface with Python backend
- **Flexible Parameters**: Tunable PID parameters and setpoints for each half

## Requirements

### Python Dependencies
Install the required Python packages:
```bash
pip install -r requirements.txt
```

### MATLAB
- MATLAB R2016b or later
- System call capability enabled

## Usage

### Configuration File Setup

All parameters are now stored in JSON configuration files. Edit `config.json` to set your parameters:

```json
{
  "input": {
    "mask_path": "path/to/mask.tif",
    "image_size": [2048, 2048]
  },
  "output": {
    "output_dir": "./output",
    "output_name": "light_control.png"
  },
  "control": {
    "left_setpoint": 0.5,
    "right_setpoint": 0.5,
    "left_pid": {
      "kp": 100,
      "ki": 1,
      "kd": 5
    },
    "right_pid": {
      "kp": 100,
      "ki": 1,
      "kd": 5
    },
    "output_limits": [0, 255]
  },
  "processing": {
    "split_method": "vertical",
    "pixel_threshold": 0,
    "normalize": true
  }
}
```

#### Key Parameters:
- **setpoint**: Target cell density (0.0-1.0 when normalized, or pixel count when not normalized)
- **normalize**: When `true`, normalizes cell count by total pixels in each half (recommended)
- **PID gains**: Adjusted for density values (larger gains needed for small density values)

### MATLAB Interface (Recommended)

#### Basic Usage
```matlab
% Uses default config.json
result = run_cell_control();
```

#### Custom Configuration File
```matlab
% Use custom config file
result = run_cell_control('config', 'config_example1.json');
```

### Python Direct Usage

```bash
# Uses default config.json
python cell_area_control.py

# Use custom config file
python cell_area_control.py --config config_example1.json
```

## File Structure

```
DMD_closed_loop_Left_right_half/
├── cell_area_control.py     # Main Python implementation
├── run_cell_control.m       # MATLAB interface
├── example_usage.m          # Usage examples
├── config.json              # Default configuration file
├── config_example1.json     # Example config for high density
├── config_example2.json     # Example config for low density
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

## Algorithm Overview

1. **Image Processing**: Load mask image and split into left/right halves
2. **Density Calculation**: Count non-zero pixels in each half and normalize by total pixels
3. **PID Control**: Apply independent PID controllers using cell density as feedback
4. **Image Generation**: Create 2048x2048 light control image
5. **Output**: Save control image to specified directory

### Cell Density Normalization

The system now normalizes cell population by dividing cell count by total pixels in each half:
- **Cell Density = Non-zero pixels / Total pixels in half**
- **Range**: 0.0 (no cells) to 1.0 (all pixels are cells)
- **Benefits**: Independent of image size, easier to set meaningful setpoints

## PID Controller

The system uses independent PID controllers for each half:
- **Proportional (Kp)**: Responds to current error
- **Integral (Ki)**: Eliminates steady-state error
- **Derivative (Kd)**: Reduces overshoot and oscillation

Output is clamped to [0, 255] range for image compatibility.

## Example Output

The system generates a 2048x2048 grayscale image where:
- Left half pixels have values corresponding to left PID output
- Right half pixels have values corresponding to right PID output
- Pixel values range from 0 (no light) to 255 (maximum light)

## Troubleshooting

### Common Issues

1. **Python not found**: Ensure Python is in system PATH
2. **Missing dependencies**: Install requirements with `pip install -r requirements.txt`
3. **Image read errors**: Check mask file path and format (should be TIF)
4. **Permission errors**: Ensure write permissions for output directory

### PID Tuning Tips

#### For Normalized Density (0.0-1.0):
- Start with Kp around 100 (larger gains needed for small density values)
- Ki values around 1-5 for steady-state error elimination
- Kd values around 5-10 to reduce oscillations
- Setpoints typically range from 0.1 to 0.8 depending on desired cell density

#### For Raw Pixel Counts (set normalize=false):
- Start with smaller Kp values (0.1) and adjust based on response
- Add Ki slowly to eliminate steady-state error
- Use Kd to reduce oscillations, but avoid excessive derivative action

#### General Tips:
- Different cell types may require different PID parameters
- Higher density targets may need more aggressive control
- Monitor system response and adjust gains accordingly