
# ADNI

Conversion scripts written by M. Stritt, 2021.

## xASL_adni_ValidateDatasets.m

Script to compare the downloaded ADNI archive with its corresponding label file. Helpful to validate if all cases have been downloaded.

## xASL_adni_Convert2Source.m

Script to convert ADNI cases to cases with a source structure. These can be converted to ASL-BIDS using ExploreASL.

## xASL_adni_Convert2BIDS.m

Script to convert the cases in source structure to ASL-BIDS using ExploreASL.

## xASL_adni_Process.m

Script to process the ADNI data.

## userConfig.json

Short example:

- `ADNI_ORIGINAL_DIR`: Path to the original ADNI data (ADNI-2 or ADNI-3).
- `ADNI_OUTPUT_DIR`: Path to the resulting BIDS & xASL derivatives data.
- `ADNI_PROCESSED`: Path a TSV file where the information about processed datasets will be stored.


```json
{
	"ADNI_VERSION": 2,	
	"ADNI_ORIGINAL_DIR": "path\\ADNI\\test_in",
	"ADNI_OUTPUT_DIR": "path\\ADNI\\test_out",
	"ADNI_PROCESSED": "path\\ADNI\\data.tsv"
}
```



