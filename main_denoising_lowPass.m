% 请同学们在此编程，完成任务（一）：基于低通滤波器傅里叶变换的灰度图像去噪任务

addpath("Data\")
addpath("Utilities\")

% 读取图像
noisy_img = imread('09_noisy.png');
GT_img = imread('09_GT.png');

% 傅里叶变换并中心化
F_noisy = fft2(double(noisy_img));
F_noisy_shifted = fftshift(F_noisy);

% 获取图像尺寸
[M, N] = size(F_noisy_shifted);

% 创建方形低通滤波器掩模
cutoff = 90; % 截止频率
H = zeros(M, N);
for u = 1:M
    for v = 1:N
        if (u - M/2)^2 + (v - N/2)^2 <= cutoff^2
            H(u, v) = 1;
        end
    end
end

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