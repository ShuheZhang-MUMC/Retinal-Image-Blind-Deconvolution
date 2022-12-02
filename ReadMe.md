<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Retinal-Image-Blind-Deconvolution/blob/main/demo/demo.png" width = "800" alt="" align=center />
</div>

# Luminosity rectified blind Richardson-Lucy deconvolution for single retinal image restoration

This is the MATLAB code for retinal image blind-deconvolution using Luminosity Rectified Blind Richardson-Lucy Deconvolution.

We are happy that this research has been accepted and published on **Computer Methods and Programs in Biomedicine** https://doi.org/10.1016/j.cmpb.2022.107297


## Abstract
**Background and Objective:** Due to imperfect imaging conditions, retinal images can be degraded by uneven/insufficient illumination, blurriness caused by optical aberrations and unintentional motions. Degraded images reduce the effectiveness of diagnosis by an ophthalmologist. To restore the image quality, in this research we propose the luminosity rectified Richardson-Lucy (LRRL) blind deconvolution framework for single retinal image restoration. 

**Methods:** We established an image formation model based on the double-pass fundus reflection feature and developed a differentiable non-convex cost function that jointly achieves illumination correction and blind deconvolution. To solve this non-convex optimization problem, we derived the closed-form expression of the gradients and used gradient descent with Nesterov-accelerated adaptive momentum estimation to accelerate the optimization, which is more efficient than the traditional half quadratic splitting method. 

**Results:**  The LRRL was tested on 1719 images from three public databases. Four image quality matrixes including image definition, image sharpness, image entropy and image multiscale contrast were used for objective assessments. The LRRL was compared against the state-of-the-art retinal image blind deconvolution methods. 

**Conclusions:** Our LRRL corrects the problematic illumination and improves the clarity of retinal image simultaneously, showing its superiority in terms of restoration quality and implementation efficiency.


## USAGE:
Run *demo_main_forAll.m* and select a retinal image from the dataset. The results will be saved in 'results' folder.

User may need to tune the model parameters in order to get better performance.


## Flow chart:
<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Retinal-Image-Blind-Deconvolution/blob/main/demo/flow.png" width = "900" alt="" align=center />
</div>


First, with the input image, we use the blind-deconvolution to obtain the estimation of illumination pattern and blurry kernel. Second, with the illumination pattern and kernel, we apply non-blind deconvolution to the input image to obtain the luminosity rectified, deconvoluted images.

### Latent images:
<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Retinal-Image-Blind-Deconvolution/blob/main/demo/Picture1.png" width = "800" alt="" align=center />
</div>


Latent images and illumination patterns for blind illumination correction and deconvolution. (a1) and (a2) are raw images in grayscale, respectively. The convolution kernels are estimated in 51-by-51 pixels and are up-sampled to 128-by-128 for better observation. (b1) and (b2) are latent images. (c1) and (c2) are latent illumination estimation. 


## Retinopathy diagnosis with restored images
Our proposed method can potentially benefit diagnising with the restoration as shown in the following figure.

<div align="center">
<img src="https://github.com/ShuheZhang-MUMC/Retinal-Image-Blind-Deconvolution/blob/main/demo/Picture2.png" width = "800" alt="" align=center />
</div>

Enhancement of retinopathy areas using proposed method. (a) Raw image. (b) Restored image. (c) Labels of retinopathy areas. Red: Hard exudates; Green: Hemorrhages; Cyan: red small dots. (d1) to (g2) are zoomed-in pictures for regions in blue, green, yellow, and red boxes. 
