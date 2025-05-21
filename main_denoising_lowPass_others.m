% 请同学们在此编程，完成任务（一）：基于低通滤波器傅里叶变换的灰度图像去噪任务
clc;clear;close all
addpath Data
addpath Utilities
noisyImage = imread('09_noisy.png'); % 有噪图
groundTruthImage = imread('09_GT.png'); % 无噪图

noisyImage = im2uint8(noisyImage);
groundTruthImage = im2uint8(groundTruthImage);

% 使用二维傅里叶变换将原图像转换到频率域
F_noisy = fft2(noisyImage);
F_noisy_shifted = fftshift(F_noisy); % 中心化
F_GT = fft2(groundTruthImage);
F_GT_shifted = fftshift(F_GT);

% 设计低通滤波器函数
%[M, N] = size(noisyImage);
%D0 = 60; % 截止频率，可以根据需要调整
%[u, v] = meshgrid(-floor(N/2):floor((N-1)/2), -floor(M/2):floor((M-1)/2));
%D = sqrt(u.^2 + v.^2); % 计算频率域中的距离
%H = double(D <= D0); % 低通滤波器函数
% 设计正方形低通滤波器函数
[M, N] = size(noisyImage);
D0 = 138; % 截止频率，可以根据需要调整
[u, v] = meshgrid(-floor(N/2):floor((N-1)/2), -floor(M/2):floor((M-1)/2));
H = double(abs(u) <= D0 & abs(v) <= D0); % 正方形低通滤波器函数

% 对傅里叶谱进行滤波
F_filtered = H .* F_noisy_shifted;

% 通过傅里叶逆变换将图像从频率域恢复到空间域
F_filtered_shifted_back = ifftshift(F_filtered);
denoisedImage = real(ifft2(F_filtered_shifted_back)); % 取实部

% 将去噪后的图像取值范围调整至 [0, 255]
denoisedImage = uint8(denoisedImage);


figure;
% 调整子图间距
subplot(2, 3, 1, 'Position', [0.01, 0.55, 0.3, 0.4]);
imshow(noisyImage, []);
title('噪声图');

subplot(2, 3, 2, 'Position', [0.34, 0.55, 0.3, 0.4]);
imshow(groundTruthImage, []);
title('原图');

subplot(2, 3, 3, 'Position', [0.67, 0.55, 0.3, 0.4]);
imshow(denoisedImage, []);
title('去噪图');

subplot(2, 3, 4, 'Position', [0.01, 0.05, 0.3, 0.4]);
imshow(log(1 + abs(F_noisy_shifted)), []);
title('噪声图傅里叶谱');

subplot(2, 3, 5, 'Position', [0.34, 0.05, 0.3, 0.4]);
imshow(log(1 + abs(F_GT_shifted)), []);
title('原图傅里叶谱');

subplot(2, 3, 6, 'Position', [0.67, 0.05, 0.3, 0.4]);
imshow(log(1 + abs(F_filtered)), []);
title('去噪后傅里叶谱');

rmse2 = rmse(denoisedImage, groundTruthImage);
psnr2 = psnr(denoisedImage, groundTruthImage);
ssim_val2 = ssim(denoisedImage, groundTruthImage);

rmse1 = rmse(noisyImage, groundTruthImage);
psnr1 = psnr(noisyImage, groundTruthImage);
ssim_val1 = ssim(noisyImage, groundTruthImage);

fprintf('FFT\n');
fprintf('RMSE: %.4f\n', rmse2);
fprintf('PSNR: %.4f\n', psnr2);
fprintf('SSIM: %.4f\n', ssim_val2);

fprintf('Original\n')
fprintf('RMSE: %.4f\n', rmse1);
fprintf('PSNR: %.4f\n', psnr1);
fprintf('SSIM: %.4f\n', ssim_val1);