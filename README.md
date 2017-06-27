# Genetic Heatmaps

The genetic heatmaps program creates minimally formatted, easy-to-read vector image heatmaps of RNA-seq gene transcription and ChIP gene binding data.

Although many [Gene Set Enrichment Analysis](https://en.wikipedia.org/wiki/Gene_set_enrichment_analysis) programs can also be used to create heatmaps, those heatmaps are typically small raster images cluttered with additional graphs and annotations, rendering them ill-suited for publication:

<img src="http://compbio.dfci.harvard.edu/pubs/ovarian_expression/html_results/gsea/gsea_s1.Gsea.1275426366765/enplot_LEADING_EDGE_247.png" title="A poorly designed heatmap made by another program" width="500"/>

In contrast, the heatmaps produced by the genetic heatmaps program:

* are completely free of any built-in annotations
* use easy-to-read color scales that clearly display the necessary data
* can be expanded to any size without losing resolution

<img src="https://image.ibb.co/e7UUsk/binding.png" title="A gene binding heatmap produced by this program" width="500"/>
<img src="https://image.ibb.co/fCAcCk/transcription.png" title="A gene transcription heatmap produced by this program" width="500"/>

## Installation

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
   chmod 755 heatmap terminal-interface.sh heatmap-generator.r
   ```

5. Copy the `heatmap` file to the `~/bin` directory.
   ```
   cp ~/.genetic-heatmaps/heatmap ~/bin
   ```

## Usage

### Syntax

```
heatmap [OPTION]... CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE BINDING_FILE
```

### Options

|   Flag   |                 Description                 |
|   ---    |                     ---                     |
| `-f`     | do not prompt before overwriting files      |
| `-i`     | prompt before overwriting files _(default)_ |
| `-n`     | do not overwrite files                      |
| `--help` | display usage notes                         |

If no options are given, the `-i` option is implied.  
If multiple options are given, only the final option takes effect.

### Arguments

|       Argument       |                                   Description                                    |
|         ---          |                                       ---                                        |
| `CSV_FILE`           | filepath of the CSV file containing the gene transcription and gene binding data |
| `LOWER_BOUND`        | minimum value on the gene transcription scale                                    |
| `UPPER_BOUND`        | maximum value on the gene transcription scale                                    |
| `TRANSCRIPTION_FILE` | filepath where the gene transcription heatmap will be saved                      |
| `BINDING_FILE`       | filepath where the gene binding heatmap will be saved                            |

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
   * Read the [arguments](https://github.com/dennisaldea/genetic-heatmaps#arguments) section for more help.

6. Ensure that the heatmaps were correctly saved to `TRANSCRIPTION_FILE` and `BINDING_FILE`.

## Dependencies

* BASH
* R
  * ggplot2
  * svglite

## Legal

Copyright 2017 by [Dennis Aldea](mailto:dennis.aldea@gmail.com).  
Released under the [MIT License](./LICENSE).
