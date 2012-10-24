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

<<<<<<< HEAD
#ITS CHANGE IN SANDBOX
=======
#THIS IS JUST A TEST FOR GIT
>>>>>>> testing

CPATH="c:\\weka\\weka.jar"
def stratXval(filestem, folds)
#Generate a new random seed for the WEKA routines
seed = rand(1000000000)

#***Special to Cow data: remove 1st attribute (timestamp)
system("java -classpath #{CPATH} weka.filters.unsupervised.attribute.Remove -R 1 -i #{filestem}.arff -o #{filestem}NoTime.arff")
filestem="#{filestem}NoTime"
#Create new train & test files for all N folds using the random seed.
1.upto(folds.to_i){|i|
  system("java -classpath #{CPATH} weka.filters.supervised.instance.StratifiedRemoveFolds -N 10 -F #{i} -S #{seed} -c last -i #{filestem}.arff -o #{filestem}Test#{i-1}.arff")
  system("java -classpath #{CPATH} weka.filters.supervised.instance.StratifiedRemoveFolds -N 10 -F #{i} -V -S #{seed} -c last -i #{filestem}.arff -o #{filestem}Train#{i-1}.arff")
}
end

# Define parameter values to explore in an array. Then loop through them over
#  all N folds.
p1=[1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 0.01, 0.1, 0.5]
p1.each {|param|
  stratXval(ARGV[0],ARGV[1])
  0.upto(ARGV[1].to_i-1) {|j|
    system("java -classpath #{CPATH} weka.classifiers.functions.Logistic -t #{ARGV[0]}Train#{j}.arff -T #{ARGV[0]}Test#{j}.arff -R #{param} > Logistic#{param}Fold#{j}.out")
  }
}


