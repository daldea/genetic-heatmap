# Genetic Heatmaps

The genetic heatmaps program is a Unix command-line tool that creates minimally formatted, easy-to-read vector image heatmaps of RNA-seq gene transcription and ChIP gene binding data.

Although many [Gene Set Enrichment Analysis](https://en.wikipedia.org/wiki/Gene_set_enrichment_analysis) programs can also be used to create heatmaps, these heatmaps are typically small raster images that are cluttered with additional graphs and annotations:

<div style="text-align: center"><img src="http://compbio.dfci.harvard.edu/pubs/ovarian_expression/html_results/gsea/gsea_s1.Gsea.1275426366765/enplot_LEADING_EDGE_247.png" title="A poorly designed heatmap made by another program" width="500"/></div>

These heatmaps contain a lot of information, but are not very useful in a publication. In contrast, the heatmaps produced by the genetic heatmaps program:

* are completely free of any built-in annotations
* use easy-to-read color scales that let the data speak for themselves
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
   chmod 755 heatmap terminal-interface.sh heatmap-generator.sh
   ```

5. Move the `heatmap` file to the `~/bin` directory.
   ```
   mv ~/.genetic-heatmaps/heatmap ~/bin
   ```

## Useage

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
| `--help` | display useage notes                        |

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
  * scale the gene transcription heatmap from `-2.5` to `2.5` 
* create a gene binding heatmap at `~/research/data/bar2.svg`

### Making your first heatmap

1. Use your favorite spreadsheet editor to create a new spreadsheet.

2. Copy-and-paste the gene transcription data into the first column.

3. Copy-and-paste the gene binding data into the second column.
   * At this point, your spreadsheet should look like the one below, but with different data:  
   <img src="https://image.ibb.co/niAvHk/spreadsheet.png" title="An example spreadsheet" width="500"/>

4. Save the spreadsheet as a _comma-separated-values_ (CSV) file.

5. Open a terminal window and type the following command:
   ```
   heatmap CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE BINDING_FILE
   ```  
   * Replace the uppercase terms with your arguments.
   * Read the [arguments](https://github.com/dennisaldea/genetic-heatmaps#arguments) section for more help.

6. Check that the  heatmaps were correctly saved to `TRANSCRIPTION_FILE` and `BINDING_FILE`.

## Dependencies

* BASH
* R
  * ggplot2
  * svglite

## Legal

Copyright 2017 by [Dennis Aldea](mailto:dennis.aldea@gmail.com).  
Released under the [MIT License](./LICENSE).
