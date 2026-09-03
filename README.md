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
The framework features a fully integrated graphical user interface (GUI), providing an accessible workflow without the need for programming expertise. SSM supports both single-subject analyses and automated batch processing of large datasets. Brain tissue metrics are extracted using the [CAT](https://neuro-jena.github.io/cat/) toolbox, while all harmonization and statistical mapping procedures are implemented within the SSM framework.<br>
<br>
**Key Features:**<br>
 - **Advanced Site Harmonization**: Embedded with SSM_combat to eliminate scanner and sequence biases (e.g., T1w vs. FLAIR) using single-subject projection algebra.<br>
 - **Biological Confounder Control**: Automatic regression for Age, Gender, and Total Intracranial Volume (TIV).<br>
 - **Fast Non-Parametric Inference**: Cluster-based permutation testing with an intelligent caching system for empirical thresholds.<br>
 - **Outlier & Quality Control**: Automated IQR-based outlier detection routines to protect the batch analysis from structural noise during harmonization.<br>

**SSM third-party prerequisites:**<br>
Before running **SSM**, ensure you have the following dependencies installed and configured in your MATLAB environment.<br>
 - **Matlab (The MathWorks Inc.)**: tested with versions from the 2019b to the 2026a<br>
      - **Matlab Parallel Computing Toolbox (optional)**<br>
 - **Statistical Parametric Mapping 25** ([SPM](https://www.fil.ion.ucl.ac.uk/spm/))<br>
 - **Computational Anatomy Toolbox** ([CAT](https://neuro-jena.github.io/cat/)) Version [3347](https://dbm.neuro.uni-jena.de/cat12/?C=M;O=D) (CAT26.0.rc4, from 2026-07-24)<br>
 - [**ComBat**](https://github.com/Jfortin1/ComBatHarmonization/tree/master) Multi-Site Harmonization Tool (Adapted version for SSM **included with SSM code**)<br>

**SSM Installation:**<br>
One of the goals during the SSM development was to ensure easy installation, broad hardware and operating system compatibility, and straightforward usability.<br>
To install SSM, download the SSM folder and add it to your MATLAB path. You may also need to download the SSM database or follow the instructions to create your own database using your own reference images.<br>

**Getting Started:**<br>
The first step is to install SSM, SPM25 and CAT in the MATLAB path.<br>
1 - Download [SPM](https://www.fil.ion.ucl.ac.uk/spm/);<br>
<br>
2 - Download [CAT](https://neuro-jena.github.io/cat/)<br>
&nbsp;&nbsp;&nbsp;&nbsp;For this version of SSM we recommend the CAT Version [3347](https://dbm.neuro.uni-jena.de/cat12/?C=M;O=D) (CAT26.0.rc4)<br>
&nbsp;&nbsp;&nbsp;&nbsp;Unzip both downloads and add the uncompressed CAT folder to the SPM toolbox folder (spm > toolbox > cat).<br>
<br>
3a - Download [SSM Database files](https://docs.google.com/forms/d/e/1FAIpQLSdkbyqeFkResFmUpGlqN3hHgSrwF3CydpqtoYqh8_40hipwlw/viewform?usp=dialog) (optional, only if you intend to use the provided SSM normative database instead of creating your own, with your own control images).<br>
&nbsp;&nbsp;&nbsp;&nbsp;Unzip the DB folder and add ITS CONTENT to the folder (SSM_v1.1 > SSM_Enc_DB). Note that each downloaded folder contains some common files, which is fine to replace or ignore if prompted.<br>
<br>
3b - Or create your own database using the SSM_CreateDatabase function<br>
<br>
4 - Add SPM (with CAT) and SSM to the MATLAB path. For example (replace "/home/user/spm25" with your actual folder path):<br>
&nbsp;&nbsp;&nbsp;&nbsp;In MATLAB Command Window (for example, replace by your real folder path):<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>> addpath(genpath('/home/user/spm25')) <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>> addpath(genpath('/home/user/SSM-v1.1')) <br>
&nbsp;&nbsp;&nbsp;&nbsp; You can also add each folder separately using the "Set Path" button in MATLAB (Environment tab), selecting "Add with Subfolders".<br>
<br>

5a - If you opted to create your own database run:<br>
&nbsp;&nbsp;&nbsp;&nbsp;In MATLAB Command Window:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>> SSM_CreateDatabase<br>
&nbsp;&nbsp;&nbsp;&nbsp;Follow the on-screen instructions to navigate the GUI.<br>
&nbsp;&nbsp;&nbsp;&nbsp;Add the "DB" folder created to the SSM main folder<br>
&nbsp;&nbsp;&nbsp;&nbsp;In MATLAB Command Window:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>> rehash<br>
&nbsp;&nbsp;&nbsp;&nbsp;"rehash" will update the Matlab Path System<br>
<br>
5b - To run SSM:<br>
&nbsp;&nbsp;&nbsp;&nbsp;In MATLAB Command Window:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>> SSM<br>
&nbsp;&nbsp;&nbsp;&nbsp;Follow the on-screen instructions to navigate the GUI. Additional guidance is available through tooltip text for each option.<br>
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

<p align="center">
  <img width="900" height="630" alt="Example of control quality plots." src="https://github.com/user-attachments/assets/e85cf34d-240a-4d20-bbac-a7f6305cbcac" />
  <br>
  <em><b>Figure 4:</b> Example of control quality plots.: Top-left, images intercorrelation and outlier detection; Top-Right, Bland-Altman plot for pre-harmonization data; Bottom-left, Bland-Altman plot for post-harmonization data; Bottom-Right, pre and post harmonization batches histograms (mean and individual);</em>
</p>

<p align="center">
  <img width="800" height="600" alt="Example of automated generated individual slice view plot." src="https://github.com/user-attachments/assets/250013cb-9405-41ae-874f-42c7cc7b5d19" />
  <br>
  <em><b>Figure 5:</b> Example of automated generated individual slice view plot;</em>
</p>

<p align="center">
  <img width="600" height="700" alt="Example of automated generated individual result report." src="https://github.com/user-attachments/assets/f78e5f8b-35de-4a77-b2a1-55bbac6532dc" />
  <br>
  <em><b>Figure 6:</b> Example of automated generated individual result anatomical report (Page 1);</em>
</p>

<p align="center">
  <img width="600" height="700" alt="Example of automated generated individual result report." src="https://github.com/user-attachments/assets/41010783-2ac4-431a-b0f3-e26c45d74ab6" />
  <br>
  <em><b>Figure 6:</b> Example of automated generated individual result anatomical report (Page 2);</em>
</p>

<p align="center">
  <img width="600" height="700" alt="Example of automated generated individual result report." src="https://github.com/user-attachments/assets/91ca768a-42e9-43e6-ac2e-12f2d45c1dfb" />
  <br>
  <em><b>Figure 6:</b> Example of automated generated individual result anatomical report (Page 3);</em>
</p>

<p align="center">
  <img width="600" height="700" alt="Example of automated generated individual result report." src="https://github.com/user-attachments/assets/0cf5ebcd-71a2-4eb7-8af9-662398943d03" />
  <br>
  <em><b>Figure 6:</b> Example of automated generated individual result anatomical report (Page 4);</em>
</p>


