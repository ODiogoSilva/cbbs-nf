// Reads paired end FastQ files as:
// [sampleA, [sampleA_1.fastq.gz, sampleA_2.fastq.gz]]
startChannel = Channel.fromFilePairs(params.fastq)


process fastQC {

	input:
	set sampleId, file(fastq) from startChannel

	output:
	set sampleId, file(fastq) into fastqcOut

	"""
	fastqc --extract --nogroup --format fastq \
	--threads ${task.cpus} ${fastq}
	"""
}

process mapping {

	publishDir "results/bowtie"

	input:
	set sampleId, file(fastq) from fastqcOut
	each file(reference) from Channel.fromPath(params.reference)

	output:
	file "*_mapping.sam"

	"""
	bowtie2-build --threads ${task.cpus} ${reference} genome_index
	bowtie2 --threads ${task.cpus} -x genome_index \
	-1 ${fastq[0]} -2 ${fastq[1]} -S ${sampleId}_mapping.sam
	"""

}
