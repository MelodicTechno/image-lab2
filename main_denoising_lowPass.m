addpath("Data/")
addpath("Utilities/")

% 读取图像
noisy_img = imread('15_noisy.png');
GT_img = imread('15_GT.png');

% 傅里叶变换并中心化
F_noisy = fft2(im2uint8(noisy_img));
F_noisy_shifted = fftshift(F_noisy);

% 获取图像尺寸
[M, N] = size(noisy_img);

% 创建圆形低通滤波器掩模
% [M, N] = size(noisyImage);
D0 = 138; % 截止频率，可以根据需要调整
[u, v] = meshgrid(-floor(N/2):floor((N-1)/2), -floor(M/2):floor((M-1)/2));
H = double(abs(3u) <= D0 & abs(v) <= D0); % 正方形低通滤波器函数
% 应用滤波器
G_noisy_shifted = F_noisy_shifted .* H;

% 逆中心化
G_noisy = ifftshift(G_noisy_shifted);

% 逆傅里叶变换
denoised_img = ifft2(G_noisy);
denoised_img = real(denoised_img);

% 缩放像素值到0-255范围并转换为uint8类型
denoised_img = im2uint8(mat2gray(denoised_img));

% 显示原始图像、去噪图像和Ground truth图像
figure;
subplot(2, 3, 1);
imshow(noisy_img, []);
title('(a) 噪声图像');

subplot(2, 3, 2);
imshow(GT_img, []);
title('(b) 原图像');

subplot(2, 3, 3);
imshow(denoised_img, []);
title('(c) 去噪图像');

% 显示傅里叶谱
% 计算原图像的傅里叶变换并中心化
F_GT = fft2(double(GT_img));
F_GT_shifted = fftshift(F_GT);

subplot(2, 3, 4);
imshow(log(1 + abs(F_noisy_shifted)), [], 'XData', [-N/2, N/2], 'YData', [-M/2, M/2]);
title('(d) 噪声图像中心化对数傅里叶谱');

subplot(2, 3, 5);
imshow(log(1 + abs(F_GT_shifted)), [], 'XData', [-N/2, N/2], 'YData', [-M/2, M/2]);
title('(e) 原图像中心化对数傅里叶谱');

% 计算去噪图像的傅里叶变换并中心化
F_denoised = fft2(double(denoised_img));
F_denoised_shifted = fftshift(F_denoised);

subplot(2, 3, 6);
imshow(log(1 + abs(F_denoised_shifted)), [], 'XData', [-N/2, N/2], 'YData', [-M/2, M/2]);
title('(f) 去噪图像中心化对数傅里叶谱');

% 计算噪声图像与原始图像之间的指标
rmse_noisy = sqrt(mean((double(GT_img) - double(noisy_img)).^2, 'all'));
mse_noisy = mean((double(GT_img) - double(noisy_img)).^2, 'all');
psnr_noisy = 10 * log10((255^2) / mse_noisy);
[ssim_noisy, ssim_map_noisy] = ssim(noisy_img, GT_img);

% 计算去噪图像与原始图像之间的指标
rmse_denoised = sqrt(mean((double(GT_img) - double(denoised_img)).^2, 'all'));
mse_denoised = mean((double(GT_img) - double(denoised_img)).^2, 'all');
psnr_denoised = 10 * log10((255^2) / mse_denoised);
[ssim_denoised, ssim_map_denoised] = ssim(denoised_img, GT_img);

% 显示结果
fprintf('噪声图像与原始图像之间的指标：\n');
fprintf('RMSE: %.4f\n', rmse_noisy);
fprintf('PSNR: %.4f dB\n', psnr_noisy);
fprintf('SSIM: %.4f\n', ssim_noisy);

fprintf('去噪图像与原始图像之间的指标：\n');
fprintf('RMSE: %.4f\n', rmse_denoised);
fprintf('PSNR: %.4f dB\n', psnr_denoised);
fprintf('SSIM: %.4f\n', ssim_denoised);