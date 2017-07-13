# Genetic Heatmap Tools

Genetic Heatmap Tools is a program that creates easy-to-read heatmaps of gene transcription and transcription factor binding data. These heatmaps are a visually attractive method of communicating how transcription factor binding affects gene expression.

Although many [Gene Set Enrichment Analysis](https://en.wikipedia.org/wiki/Gene_set_enrichment_analysis) programs can also be used to create similar heatmaps, those heatmaps are typically cluttered with additional graphs and annotations, rendering them ill-suited for publication:

<img src="https://image.ibb.co/iWpt7v/gsea.png" title="A poorly designed heatmap made by another program" width="500"/>

In contrast, the heatmaps produced by the genetic heatmaps program:

* are completely free of distracting annotations
* use easy-to-read color scales that clearly display the data
* can be expanded to any size without losing resolution

<img src="https://image.ibb.co/ei52Za/b.png" title="A gene binding heatmap produced by this program" width="500"/>
<img src="https://image.ibb.co/dH91Sv/t.png" title="A gene transcription heatmap produced by this program" width="500"/>

## Installation

### Automatic Installation

1. [Download](https://raw.githubusercontent.com/dennisaldea/genetic-heatmaps/analysis/installer.sh) the installer script.
   ```
   cd ~/Downloads
   wget https://raw.githubusercontent.com/dennisaldea/genetic-heatmaps/analysis/installer.sh
   ```

2. Run the installation script.
   ```
   ./installer.sh
   ```

_Note:_ The installer script only installs Genetic Heatmap Tools for the user running the script. To install Genetic Heatmap Tools for all users, modify the steps listed in the [Manual Installation](https://github.com/dennisaldea/genetic-heatmaps#manual-installation) section.

### Manual Installation

1. [Download](https://github.com/dennisaldea/genetic-heatmaps/archive/master.tar.gz) the repository.
   ```
   cd ~/Downloads
   wget https://github.com/dennisaldea/genetic-heatmaps/archive/master.tar.gz
   ```

2. Extract the TAR archive.
   ```
   tar -xzvf master.tar.gz
   rm master.tar.gz
   ```

3. Move the extracted files to the `~/.genetic-heatmaps` directory.
   ```
   mkdir ~/.genetic-heatmaps
   mv -T genetic-heatmaps-master ~/.genetic-heatmaps
   ```

4. Mark the code files as executable.
   ```
   cd ~/.genetic-heatmaps
   chmod 755 *
   chmod 644 README.md LICENSE HELP/*
   ```

5. Copy the alias file to the `~/bin` directory.
   ```
   cp ~/.genetic-heatmaps/ghmtools ~/bin
   ```

## Usage

### Syntax

```
heatmap [OPTION]... CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE BINDING_FILE
```

### Options

|   Option    |                   Description                   |
|     ---     |                       ---                       |
| `--help`    | display usage documentation                     |
| `--nozeros` | do not map genes with zero transcription values |
| `-f`        | do not prompt before overwriting files          |
| `-i`        | prompt before overwriting files _(default)_     |
| `-n`        | do not overwrite files                          |

If neither `-f`, `-i`, nor `-n` are given, the `-i` option is implied.  
If conflicting options are given, the last option given takes effect.

### Arguments

|       Argument       |                                   Description                                    |
|         ---          |                                       ---                                        |
| `CSV_FILE`           | filepath of the CSV file containing gene transcription and gene binding data     |
| `TRANSCRIPTION_MAX`  | minimum value on the gene transcription scale                                    |
| `TRANSCRIPTION_MIN`  | maximum value on the gene transcription scale                                    |
| `BINDING_MAX`        | maximum value on the gene binding scale _(optional)_                             |
| `TRANSCRIPTION_FILE` | filepath where the gene transcription heatmap will be saved                      |
| `BINDING_FILE`       | filepath where the gene binding heatmap will be saved                            |

If `BINDING_MAX` is not given or is set to `NONE`, the maximum gene binding value in the data set becomes the maximum value on the gene binding scale.

### Example

```
heatmap ~/research/data/foo.csv -2.5 2.5 ~/research/figures/bar1.svg ~/research/figures/bar2.svg
```

* use the data at `~/research/data/foo.csv`
* create a gene transcription heatmap at `~/research/figures/bar1.svg`
  * scale the heatmap from `-2.5` to `2.5`
* create a gene binding heatmap at `~/research/data/bar2.svg`

### Making your first heatmap

1. Use your preferred spreadsheet editor to create a new spreadsheet.

2. Copy-and-paste the gene transcription data into the first column.

3. Copy-and-paste the gene binding data into the second column.
   * At this point, your spreadsheet should look similar to the example below (albeit with different data).  
     <img src="https://image.ibb.co/niAvHk/spreadsheet.png" title="An example spreadsheet" width="250"/>

4. Save the spreadsheet as a comma-separated-values (CSV) file.

5. Open a terminal window and type the command:
   ```
   heatmap CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE BINDING_FILE
   ```  
   * Replace the uppercase terms with your arguments.
   * Read the [usage](https://github.com/dennisaldea/genetic-heatmaps#usage) section for more help.

6. Ensure that the heatmaps were correctly saved to `TRANSCRIPTION_FILE` and `BINDING_FILE`.

## Dependencies

* BASH
* R
  * ggplot2
  * svglite

## Legal

Copyright 2017 by [Dennis Aldea](mailto:dennis.aldea@gmail.com).  
Released under the [MIT License](./LICENSE).
