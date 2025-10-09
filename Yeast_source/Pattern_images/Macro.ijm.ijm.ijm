// === Wenqi Gu — True RGB Fusion Macro (LUT-based, no multi-channel) ===
// 功能：将灰度序列(LUT红)与pattern图像(LUT蓝)逐帧合成为真正的8-bit RGB stack
// tested with Fiji/ImageJ 1.54+ / 2025
// =====================================================

// ===================== 设置区 =====================
singleTitle = "Captured DMD_pattern_GE_clear.nd2";   // pattern图像标题（蓝色LUT）
redLUT = "Red";                                  // 序列LUT
blueLUT = "Blue";                                // patternLUT
basePath = "Y:/khammash/MC/microscope/CyGenTiG_Analysis/Yeast_20251009/Pattern_images/";
// =================================================

// 自动生成带时间戳的输出文件名
timestamp = replace(getInfo("log.time"), " ", "_");
timestamp = replace(timestamp, ":", "");
outputPath = basePath + "Merged_RGB_Final_" + timestamp + ".tif";

// 获取所有已打开图像标题
titles = getList("image.titles");
print("Currently opened images:");
for (i = 0; i < titles.length; i++) print(i + ": " + titles[i]);

// 自动识别序列标题
for (i = 0; i < titles.length; i++) {
    if (titles[i] != singleTitle) {
        seqTitle = titles[i];
        break;
    }
}

print("Pattern (Blue LUT): " + singleTitle);
print("Sequence (Red LUT): " + seqTitle);

// 检查是否都打开
if (isOpen(singleTitle) == 0 || isOpen(seqTitle) == 0)
    exit("❌ 请确认两个图像窗口都已打开！");

// 获取序列信息
selectImage(seqTitle);
totalSlices = nSlices;
width = getWidth();
height = getHeight();
print("Detected " + totalSlices + " slices, target size: " + width + "x" + height);

// 创建结果stack
run("New...", "name=Merged_RGB_Final type=RGB width="+width+" height="+height+" slices="+totalSlices+" fill=Black");

// 主循环
for (i = 1; i <= totalSlices; i++) {
    // --- 处理序列帧 (红LUT) ---
    selectImage(seqTitle);
    setSlice(i);
    run("Duplicate...", "title=tempSeq");
    run("8-bit");
    run(redLUT);      // 载入LUT
    run("Apply LUT"); // 应用伪彩
    run("RGB Color"); // 转为真正RGB
    rename("tempSeq_RGB");

    // --- 处理pattern图像 (蓝LUT) ---
    selectImage(singleTitle);
    run("Duplicate...", "title=tempPattern");
    run("8-bit");
    run(blueLUT);
    run("Apply LUT");
    run("RGB Color");
    rename("tempPattern_RGB");

    // === 校正尺寸 (居中补齐) ===
    selectWindow("tempPattern_RGB");
    bW = getWidth();
    bH = getHeight();
    if (bW != width || bH != height) {
        print("Resizing pattern: " + bW + "x" + bH + " → " + width + "x" + height);
        run("Canvas Size...", "width="+width+" height="+height+" position=Center zero");
    }

    // --- 将两张RGB叠加 ---
    imageCalculator("Add create", "tempSeq_RGB", "tempPattern_RGB");
    rename("merged_temp");

    // ⚠️ 强制转换为RGB Color（避免 composite channel stack）
    run("RGB Color");

    // --- 粘贴到结果stack ---
    selectWindow("merged_temp");
    run("Copy");
    selectWindow("Merged_RGB_Final");
    setSlice(i);
    run("Paste");

    // --- 清理临时图像 ---
    close("tempSeq");
    close("tempSeq_RGB");
    close("tempPattern");
    close("tempPattern_RGB");
    close("merged_temp");
    while (isOpen("Composite")) close("Composite");
}

// 输出
selectWindow("Merged_RGB_Final");
run("RGB Color"); // 确保最终stack为RGB
print("✅ RGB fusion complete! Output: Merged_RGB_Final");

// 自动保存输出
saveAs("Tiff", outputPath);
print("💾 Saved RGB merged sequence to: " + outputPath);
