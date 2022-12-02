<img src="https://github.com/ShuheZhang-MUMC/Retinal-Image-Blind-Deconvolution/blob/main/demo/demo.png" width = "800" alt="" align=center />

# Luminosity rectified blind Richardson-Lucy deconvolution for single retinal image restoration
This is the MATLAB code for retinal image blind-deconvolution using Luminosity Rectified Blind Richardson-Lucy Deconvolution.
We are happy that this research has been accepted and published on Computer Methods and Programs in Biomedicine

### USAGE:
Run *demo_main_forAll.m* and select a retinal image from the dataset. The results will be saved in 'results' folder.
User may need to tune the model parameters in order to get better performance.

### Flow chart:
First, with the input image, we use the blind-deconvolution to obtain the estimation of illumination pattern and blurry kernel (Section 3.1 and 3.2). Second, with the illumination pattern and kernel, we apply non-blind deconvolution (Section 3.3) to the input image to obtain the luminosity rectified, deconvoluted images.
