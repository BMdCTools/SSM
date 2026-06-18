# <p align="center"> Single-Subject Morphometry Tool </p>
 -------------------------------------------------------------------------
           ____   ____   __  __ 
          / ___| / ___| |  \/  |
          \___ \ \___ \ | |\/| |   Single-Subject Morphometry Tool, v1.1
           ___) | ___) || |  | |
          |____/ |____/ |_|  |_|
 -------------------------------------------------------------------------
***SSM (Single-Subject Morphometry)*** is an open-source framework for individualized assessment of brain structural abnormalities using MRI. The software generates subject-specific maps of white and gray matter alterations and focal cortical dysplasia lesions based on normative models derived from healthy controls, enabling the detection and quantification of morphometric abnormalities at the voxel level. **SSM** supports the evaluation of atrophy, hypertrophy, and focal cortical dysplasia (FCD) recquiring only a high-quality T1-weighted MRI scan (FLAIR image optional). Demographic variables such as age and sex can be incorporated to improve model accuracy but are not required.<br>
<br>
The framework features a fully integrated graphical user interface (GUI), providing an accessible workflow without the need for programming expertise. SSM supports both single-subject analyses and automated batch processing of large datasets. Brain tissue metrics are extracted using the [CAT12](https://neuro-jena.github.io/cat/) toolbox, while all harmonization and statistical mapping procedures are implemented within the SSM framework.<br>
<br>
**Key Features:**<br>
 - **Advanced Site Harmonization**: Embedded with SSM_combat to eliminate scanner and sequence biases (e.g., T1w vs. FLAIR) using single-subject projection algebra.<br>
 - **Biological Confounder Control**: Automatic regression for Age, Gender, and Total Intracranial Volume (TIV).<br>
 - **Fast Non-Parametric Inference**: Cluster-based permutation testing with an intelligent caching system for empirical thresholds.<br>
 - **Outlier & Quality Control**: Automated IQR-based outlier detection routines to protect the batch analysis from structural noise during harmonization.<br>

**SSM third-party prerequisites:**<br>
Before running **SSM**, ensure you have the following dependencies installed and configured in your MATLAB environment.<br>
 - **Matlab (The MAthWorks Inc.)**: tested with versions from the 2019b to the 2026a<br>
      - **Matlab Parallel Computing Toolbox (optional)**<br>
 - **Statistical Parametric Mapping 25** ([SPM](https://www.fil.ion.ucl.ac.uk/spm/))<br>
 - **Computational Anatomy Toolbox** ([CAT12](https://neuro-jena.github.io/cat/))<br>
 - [**ComBat**](https://github.com/Jfortin1/ComBatHarmonization/tree/master) Multi-Site Harmonization Tool (Adapted version for SSM **included with SSM code**)<br>

 **SSM Installation:**<br>
One of the goals during the SSM development was to ensure easy installation, broad hardware and operating system compatibility, and straightforward usability.<br>
To install SSM, download the SSM folder and add it to your MATLAB path. You may also need to download the SSM database or follow the instructions to create your own database using your own reference images.


**Getting Started:**<br>
In the MATLAB Command Window, type: ```SSM``` <br>
Follow the on-screen instructions to navigate the GUI. Additional guidance is available through the tooltip associated with each option.<br>

<br>
<p align="right">
SSM was developed by Brunno M Campos, Ph.D. (brunno at unicamp dot br)<br>
University of Campinas, Neuroimaging Laboratory<br>
</p>
<br>
Example images:<br>

<p align="center">
  <img width="400" height="600" alt="SSM graphical user interface (GUI)" src="https://github.com/user-attachments/assets/f626fa54-33e4-44ad-90cf-dff1c7fd2f2c" />
 <br>
  <em><b>Figure 1:</b> SSM graphical user interface (GUI).</em>
</p>

<p align="center">
  <img width="1200" height="500" alt="Example resut for focal cortical dysplasia (blue maps: drawn ROI; hot-scaled map: SSM result)" src="https://github.com/user-attachments/assets/ff6d6254-de1f-4cc4-8153-b31c44873a61" />
  <br>
  <em><b>Figure 2:</b> Example resut for focal cortical dysplasia (blue maps: drawn ROI; hot-scaled map: SSM FCD result).</em>
</p>

<p align="center">
  <img width="1344" height="570" alt="Example resut for Grey Matter Atrophy Study on patient with left mesia temporal lobe epilepsy (hot-scaled map: SSM individual atrophy map)" src="https://github.com/user-attachments/assets/345c3d9f-7292-4230-a3a9-115a0c2a9e19" />
  <br>
  <em><b>Figure 3:</b> Example resut for Grey Matter Atrophy Study on patient with left mesial temporal lobe epilepsy (hot-scaled map: SSM individual atrophy map).</em>
</p>



