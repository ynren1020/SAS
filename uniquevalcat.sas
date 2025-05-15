proc sort data=electrodes; by PROGRAMMER_REPORT_ID cathode; run;
proc transpose data = electrodes out = cathodes prefix = cathode_;
	by PROGRAMMER_REPORT_ID;
	var cathode;
run;
data cathodes2;
	set cathodes;
	length value $100 cathodes_all $200;
	cathodes = catx(',', of cathode_1-cathode_24);
	
	array nums[100] _temporary_;
	n = 0;

	do i = 1 to countw(cathodes, ',');
		value = scan(cathodes, i, ',');
		num = input(value, best.);

		found = 0;
		do j = 1 to n;
			if nums[j] = num then found = 1;
		end;
        if not found then do;
		n + 1;
		nums[n] = num;
		end;
	end;

	do i = 1 to n-1;
		do j = i+1 to n;
			if nums[i] > nums[j] then do;
			temp = nums[i];
			nums[i] = nums[j];
			nums[j] = temp;
		end;
	end;
end;

cathodes_all = '';
do i = 1 to n;
	cathodes_all = catx(',', cathodes_all, put(nums[i], best.));
end;

keep programmer_report_id cathodes_all;
run;



%macro processElectrodes(dataset=, var=, prefix=);

    /* Sort the data by PROGRAMMER_REPORT_ID and the specified variable */
    proc sort data=&dataset;
        by PROGRAMMER_REPORT_ID &var;
    run;

    /* Transpose the data, creating variables prefixed with the specified prefix */
    proc transpose data=&dataset out=transposed prefix=&prefix;
        by PROGRAMMER_REPORT_ID;
        var &var;
    run;

    /* Process the transposed data to concatenate and sort unique values */
    data processed;
        set transposed;
        length value $100 combined $200;
        
        /* Concatenate transposed variables into a single string */
        concatenated = catx(',', of &prefix._1-&prefix._24);
        
        /* Initialize an array to store unique numbers and a counter */
        array nums[100] _temporary_;
        n = 0;

        /* Loop through each value in the concatenated string */
        do i = 1 to countw(concatenated, ',');
            value = scan(concatenated, i, ',');
            num = input(value, best.);

            /* Check if the number is already in the array */
            found = 0;
            do j = 1 to n;
                if nums[j] = num then found = 1;
            end;

            /* If the number is unique, add it to the array */
            if not found then do;
                n + 1;
                nums[n] = num;
            end;
        end;

        /* Sort the numbers in the array */
        do i = 1 to n-1;
            do j = i+1 to n;
                if nums[i] > nums[j] then do;
                    temp = nums[i];
                    nums[i] = nums[j];
                    nums[j] = temp;
                end;
            end;
        end;

        /* Concatenate sorted unique numbers into a single string */
        combined = '';
        do i = 1 to n;
            combined = catx(',', combined, put(nums[i], best.));
        end;

        /* Keep only relevant variables */
        keep PROGRAMMER_REPORT_ID combined;
    run;

%mend processElectrodes;

/* Example usage of the macro */
%processElectrodes(dataset=electrodes, var=cathode, prefix=cathode);

Parameters:

dataset: The input dataset name.
var: The variable to be transposed.
prefix: The prefix for transposed variables.
Flexibility: The macro can be used with any dataset that has a similar structure by specifying the dataset, variable, and prefix.

Sorting and Transposing: Uses proc sort and proc transpose to prepare the data.

Processing: Handles concatenation, uniqueness check, sorting, and final concatenation of values.

Output: Keeps only PROGRAMMER_REPORT_ID and the final concatenated string.
