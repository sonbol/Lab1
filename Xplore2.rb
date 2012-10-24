#**************************************************************************
#*                                                                        *
#*                        Parameter Exploration                           *
#*                              Scott Dick                                *
#*                              Fall 2011                                 *
#*                                                                        *
#**************************************************************************

# A Ruby routine that performs a proper parameter exploration, in an N-fold
#  cross-validation design, using WEKA. Parameters to be varied, and their 
#  values, have to be set in this file; it's too complicated to pass them. 
#  The two arguments to be passed in are the filestem for the original ARFF
#  file, and the number of folds in the cross-validation. For each parameter
#  setting, a new stratified partitioning (using a properly changing random
#  seed) will be generated using WEKA's filters. The parameter values will
#  be an array that is looped through using Ruby's routines. 

# In this version, I will still pass all output to an output file, to be 
#  further processed by another script. When I am more comfortable with Ruby
#  regular expressions, this will be changed. The plan will be to replace the
#  "system" calls with backticks, and store the output of the WEKA programs 
#  in a Ruby string variable. I will then directly process that data in Ruby, 
#  and likely just output the confusion matrix file for the N-fold xval. I 
#  *could* also generate the metrics directly; but I already spent the time
#  to build Java code that does that. If I can just eliminate the Windows 
#  batch files and Linux scripts (and reliance on grep), then my toolchain
#  will be fully portable insterad of split between many devices. That's
#  all I really need for productivity improvement.

#SONBOL: CHANGE THE cpath TO WHATEVER THE FULL PATH TO WEKA.JAR IS ON YOUR SYSTEM.
CPATH="C:\\Weka-3-7\\weka.jar"
as=Array.new
b=Array.new
#bs=0
k=0
def stratXval(train6cd, folds)
#Generate a new random seed for the WEKA routines
seed = rand(1000000000)

#***Special to Cow data: remove 1st attribute (timestamp). SONBOL: COMMENT THIS OUT!
#system("java -classpath #{CPATH} weka.filters.unsupervised.attribute.Remove -R 1 -i #{filestem}.arff -o #{filestem}NoTime.arff")
#filestem="#{filestem}NoTime"
system("java -classpath #{CPATH} weka.filters.supervised.attribute.AttributeSelection -S weka.attributeSelection.Ranker -E weka.attributeSelection.InfoGainAttributeEval -i #{train6cd}.arff -o #{train6cd}InfoGain.arff")
train6cd="#{train6cd}InfoGain"

#system("java -classpath #{CPATH} weka.filters.supervised.attribute.AttributeSelection -i #{train6cd}.arff -o #{train6cd}InfoGain.arff")
#train6cd="#{train6cd}InfoGain"
#system("java -classpath #{CPATH} weka.attributeSelection.InfoGainAttributeEval -i #{train6cd}.arff ")
#train6cd="#{train6cd}InfGain"
system("java -classpath #{CPATH} weka.filters.unsupervised.attribute.Remove -R 19-24 -i #{train6cd}.arff -o #{train6cd}RemoveOne.arff")
train6cd="#{train6cd}RemoveOne"
#Create new train & test files for all N folds using the random seed.
#SONBOL: AS AN IMPROVEMENT, MAKE THE SYSTEM CALLS WORK FOR ANY NUMBER OF FOLDS
1.upto(folds.to_i){|i|
  system("java -classpath #{CPATH} weka.filters.supervised.instance.StratifiedRemoveFolds -N 10 -F #{i} -S #{seed} -c last -i #{train6cd}.arff -o #{train6cd}Test#{i-1}.arff")
  system("java -classpath #{CPATH} weka.filters.supervised.instance.StratifiedRemoveFolds -N 10 -F #{i} -V -S #{seed} -c last -i #{train6cd}.arff -o #{train6cd}Train#{i-1}.arff")
}
end


# Define parameter values to explore in an array. Then loop through them over
#  all N folds.
# SONBOL: TO ADD MORE PARAMETERS, CREATE MORE ARRAYS WITH VALUES FOR EACH PARAMETER, AND THEN NESTED LOOPS ITERATING THROUGH ALL ARRAYS.
p1=[1e-8]#, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 0.01, 0.1, 0.5]
p1.each {|param|
  stratXval(ARGV[0],ARGV[1])
  0.upto(ARGV[1].to_i-1) {|j|
    system("java -classpath #{CPATH} weka.classifiers.functions.Logistic -t #{ARGV[0]}Train#{j}.arff -T #{ARGV[0]}Test#{j}.arff -R #{param} > Logistic#{param}Fold#{j}.out")
str=File.open("Logistic#{param}Fold#{j}.out")
	str1=str.readlines
   poo=str1[93]   
	md=/(\w+)(\s*)(((|-)(\d)(\.)(\d+))|0)/.match(poo)
    #puts "#{md}"
   as[j]="#{md[3]}"
	#NEXT STEP: COMBINE ALL TEN FILES FOR EACH PARAMETER COMBINATION.
	#puts ("java -classpath #{CPATH} weka.classifiers.functions.Logistic -t #{ARGV[0]}Train#{j}.arff -T #{ARGV[0]}Test#{j}.arff -R #{param} > Logistic#{param}Fold#{j}.out")
  }
 as.collect! {|i| i.to_f} 
#puts as.inject(:+)
bs=as.inject(:+)
 b[k]= bs/10
k+=1
}
puts b
 #as.each{|i| puts i}
#as.collect! {|i| i.to_f} 


#puts as.inject(:+)
#bs=as.inject(:+)
#puts bs/10
#puts as.class
 #bs=as.to_i
#puts as.scan(/\d+/).inject(:+)




#puts "#{md[3]}"
#str=File.open('Logistic1.0e-08Fold0.out')
#str1=str.readlines
#po= str1[93]
#po=~/(\w+)(\s*)((\d)(\.)(\d+))/
#puts $3





