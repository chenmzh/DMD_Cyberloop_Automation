#!/usr/bin/env python3
"""
PID History Plotting Tool

This script reads PID history files and creates plots showing:
- Error vs time
- Integral vs time  
- Light output vs time
- Current value vs setpoint over time

Usage:
    python plot_pid_history.py [--sequence N] [--output-dir path]
"""

import json
import os
import argparse
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path


def load_pid_history(history_file):
    """Load PID history from JSON file"""
    try:
        with open(history_file, 'r') as f:
            data = json.load(f)
            # Handle case where data is nested in multiple array layers
            if isinstance(data, list) and len(data) > 0 and isinstance(data[0], list):
                # Flatten nested arrays into a single list
                flattened = []
                for sublist in data:
                    if isinstance(sublist, list):
                        flattened.extend(sublist)
                    else:
                        flattened.append(sublist)
                data = flattened
            return data
    except Exception as e:
        print(f"Error loading history file {history_file}: {e}")
        return None


def plot_pid_sequence(history_data, sequence, save_path=None):
    """Plot PID data for a single sequence"""
    if not history_data:
        print(f"No data to plot for sequence {sequence}")
        return
    
    # Extract data
    frames = [record['frame'] for record in history_data]
    timestamps = [record.get('timestamp', 0) for record in history_data]
    
    # Left side data
    left_values = [record['left_state']['current_value'] for record in history_data]
    left_errors = [record['left_state']['error'] for record in history_data]
    left_integrals = [record['left_state']['integral'] for record in history_data]
    left_lights = [record['left_state']['light_output'] for record in history_data]
    left_setpoint = history_data[0]['left_state']['setpoint']
    
    # Right side data
    right_values = [record['right_state']['current_value'] for record in history_data]
    right_errors = [record['right_state']['error'] for record in history_data]
    right_integrals = [record['right_state']['integral'] for record in history_data]
    right_lights = [record['right_state']['light_output'] for record in history_data]
    right_setpoint = history_data[0]['right_state']['setpoint']
    
    # Create subplots
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle(f'PID Control History - Sequence {sequence}', fontsize=16)
    
    # Plot 1: Current values vs setpoint
    axes[0, 0].plot(frames, left_values, 'b-', label='Left Current', linewidth=2)
    axes[0, 0].plot(frames, right_values, 'r-', label='Right Current', linewidth=2)
    axes[0, 0].axhline(y=left_setpoint, color='b', linestyle='--', alpha=0.7, label=f'Left Setpoint ({left_setpoint})')
    axes[0, 0].axhline(y=right_setpoint, color='r', linestyle='--', alpha=0.7, label=f'Right Setpoint ({right_setpoint})')
    axes[0, 0].set_xlabel('Frame')
    axes[0, 0].set_ylabel('Density/Area Value')
    axes[0, 0].set_title('Current Values vs Setpoints')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)
    
    # Plot 2: Errors over time
    axes[0, 1].plot(frames, left_errors, 'b-', label='Left Error', linewidth=2)
    axes[0, 1].plot(frames, right_errors, 'r-', label='Right Error', linewidth=2)
    axes[0, 1].axhline(y=0, color='k', linestyle='-', alpha=0.3)
    axes[0, 1].set_xlabel('Frame')
    axes[0, 1].set_ylabel('Error (Setpoint - Current)')
    axes[0, 1].set_title('Control Errors Over Time')
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)
    
    # Plot 3: Integral terms
    axes[1, 0].plot(frames, left_integrals, 'b-', label='Left Integral', linewidth=2)
    axes[1, 0].plot(frames, right_integrals, 'r-', label='Right Integral', linewidth=2)
    axes[1, 0].axhline(y=0, color='k', linestyle='-', alpha=0.3)
    axes[1, 0].set_xlabel('Frame')
    axes[1, 0].set_ylabel('Integral Term')
    axes[1, 0].set_title('PID Integral Accumulation')
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)
    
    # Plot 4: Light outputs
    axes[1, 1].plot(frames, left_lights, 'b-', label='Left Light', linewidth=2)
    axes[1, 1].plot(frames, right_lights, 'r-', label='Right Light', linewidth=2)
    axes[1, 1].set_xlabel('Frame')
    axes[1, 1].set_ylabel('Light Intensity')
    axes[1, 1].set_title('Control Light Outputs')
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    # Save or show
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Plot saved to: {save_path}")
    else:
        plt.show()


def plot_all_samples_combined(history_files, save_path=None):
    """Plot all samples' left and right area values over time in combined plots"""
    
    # Create figure with 2 subplots (left and right areas)
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(15, 12))
    fig.suptitle('Cell Area Density Over Time - All Samples', fontsize=16)
    
    # Color map for different samples
    colors = plt.cm.tab10(np.linspace(0, 1, len(history_files)))
    
    left_setpoint = None
    right_setpoint = None
    
    # Process each sample
    for i, (sequence, history_file) in enumerate(history_files):
        history_data = load_pid_history(history_file)
        if not history_data:
            continue
            
        # Extract data
        frames = [record['frame'] for record in history_data]
        left_values = [record['left_state']['current_value'] for record in history_data]
        right_values = [record['right_state']['current_value'] for record in history_data]
        
        # Get setpoints (should be same for all samples)
        if left_setpoint is None:
            left_setpoint = history_data[0]['left_state']['setpoint']
            right_setpoint = history_data[0]['right_state']['setpoint']
        
        # Plot left areas
        ax1.plot(frames, left_values, color=colors[i], linewidth=2, 
                label=f'Sample {sequence}', marker='o', markersize=4, alpha=0.8)
        
        # Plot right areas
        ax2.plot(frames, right_values, color=colors[i], linewidth=2, 
                label=f'Sample {sequence}', marker='s', markersize=4, alpha=0.8)
    
    # Add setpoint lines
    if left_setpoint is not None:
        ax1.axhline(y=left_setpoint, color='red', linestyle='--', linewidth=2, 
                   alpha=0.7, label=f'Setpoint ({left_setpoint})')
        ax2.axhline(y=right_setpoint, color='red', linestyle='--', linewidth=2, 
                   alpha=0.7, label=f'Setpoint ({right_setpoint})')
    
    # Configure left area plot
    ax1.set_xlabel('Time Point (Frame)')
    ax1.set_ylabel('Left Area Density')
    ax1.set_title('Left Side Cell Area Density Over Time')
    ax1.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    ax1.grid(True, alpha=0.3)
    
    # Configure right area plot
    ax2.set_xlabel('Time Point (Frame)')
    ax2.set_ylabel('Right Area Density')
    ax2.set_title('Right Side Cell Area Density Over Time')
    ax2.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    # Save or show
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Combined plot saved to: {save_path}")
    else:
        plt.show()


def plot_summary_statistics(history_files, save_path=None):
    """Plot summary statistics across all samples"""
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Summary Statistics - All Samples', fontsize=16)
    
    all_left_values = []
    all_right_values = []
    all_left_lights = []
    all_right_lights = []
    sample_labels = []
    
    # Collect data from all samples
    for sequence, history_file in history_files:
        history_data = load_pid_history(history_file)
        if not history_data:
            continue
            
        left_values = [record['left_state']['current_value'] for record in history_data]
        right_values = [record['right_state']['current_value'] for record in history_data]
        left_lights = [record['left_state']['light_output'] for record in history_data]
        right_lights = [record['right_state']['light_output'] for record in history_data]
        
        all_left_values.append(left_values)
        all_right_values.append(right_values)
        all_left_lights.append(left_lights)
        all_right_lights.append(right_lights)
        sample_labels.append(f'Sample {sequence}')
    
    if not all_left_values:
        print("No data to plot")
        return
    
    # Plot 1: Left area box plot
    axes[0, 0].boxplot(all_left_values, tick_labels=sample_labels)
    axes[0, 0].set_title('Left Area Density Distribution')
    axes[0, 0].set_ylabel('Density')
    axes[0, 0].tick_params(axis='x', rotation=45)
    
    # Plot 2: Right area box plot
    axes[0, 1].boxplot(all_right_values, tick_labels=sample_labels)
    axes[0, 1].set_title('Right Area Density Distribution')
    axes[0, 1].set_ylabel('Density')
    axes[0, 1].tick_params(axis='x', rotation=45)
    
    # Plot 3: Left light box plot
    axes[1, 0].boxplot(all_left_lights, tick_labels=sample_labels)
    axes[1, 0].set_title('Left Light Output Distribution')
    axes[1, 0].set_ylabel('Light Intensity')
    axes[1, 0].tick_params(axis='x', rotation=45)
    
    # Plot 4: Right light box plot
    axes[1, 1].boxplot(all_right_lights, tick_labels=sample_labels)
    axes[1, 1].set_title('Right Light Output Distribution')
    axes[1, 1].set_ylabel('Light Intensity')
    axes[1, 1].tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    
    # Save or show
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Summary statistics plot saved to: {save_path}")
    else:
        plt.show()


def main():
    parser = argparse.ArgumentParser(description='Plot PID control history')
    parser.add_argument('--output-dir', default='./output', help='Output directory containing pid_states')
    parser.add_argument('--sequence', type=int, help='Specific sequence to plot (if not specified, plots all sequences)')
    parser.add_argument('--save', action='store_true', help='Save plots instead of showing them')
    parser.add_argument('--save-dir', default='./plots', help='Directory to save plots')
    parser.add_argument('--combined', action='store_true', help='Create combined plots for all samples')
    parser.add_argument('--summary', action='store_true', help='Create summary statistics plots')
    
    args = parser.parse_args()
    
    # Find PID history files
    pid_states_dir = os.path.join(args.output_dir, 'pid_states')
    
    if not os.path.exists(pid_states_dir):
        print(f"PID states directory not found: {pid_states_dir}")
        return
    
    # Find all history files
    history_files = []
    for file in os.listdir(pid_states_dir):
        if file.startswith('pid_history_') and file.endswith('.json'):
            sequence_num = int(file.split('_')[2].split('.')[0])
            history_files.append((sequence_num, os.path.join(pid_states_dir, file)))
    
    if not history_files:
        print("No PID history files found")
        return
    
    history_files.sort()  # Sort by sequence number
    
    # Filter by sequence if specified
    if args.sequence is not None:
        history_files = [(seq, path) for seq, path in history_files if seq == args.sequence]
        if not history_files:
            print(f"No history found for sequence {args.sequence}")
            return
    
    # Create save directory if needed
    if args.save:
        os.makedirs(args.save_dir, exist_ok=True)
    
    # Create combined plots if requested
    if args.combined or (args.sequence is None and len(history_files) > 1):
        print("Creating combined plots for all samples...")
        save_path = None
        if args.save:
            save_path = os.path.join(args.save_dir, 'combined_all_samples.png')
        plot_all_samples_combined(history_files, save_path)
    
    # Create summary statistics if requested
    if args.summary:
        print("Creating summary statistics plots...")
        save_path = None
        if args.save:
            save_path = os.path.join(args.save_dir, 'summary_statistics.png')
        plot_summary_statistics(history_files, save_path)
    
    # Plot individual sequences (unless only combined plots were requested)
    if not args.combined or args.sequence is not None:
        for sequence, history_file in history_files:
            print(f"Processing sequence {sequence}...")
            
            history_data = load_pid_history(history_file)
            if history_data:
                save_path = None
                if args.save:
                    save_path = os.path.join(args.save_dir, f'pid_history_sequence_{sequence}.png')
                
                plot_pid_sequence(history_data, sequence, save_path)
            else:
                print(f"Failed to load data for sequence {sequence}")


if __name__ == "__main__":
    main()