# Let's do some changes in the first subdirectory

CPATH="C:\\Weka-3-7\\weka.jar"
def stratXval(train6cd, folds)
seed = rand(1000000000)
system("java -classpath #{CPATH} weka.filters.supervised.attribute.AttributeSelection -E weka.attributeSelection.InfoGainAttributeEval -S weka.attributeSelection.Ranker  -i #{train6cd}.arff -o #{train6cd}Ig.arff")

system("java -classpath #{CPATH} weka.filters.unsupervised.attribute.Remove -R 19-24 -i #{train6cd}Ig.arff -o #{train6cd}Rn.arff")

1.upto(folds.to_i){|i|
  system("java -classpath #{CPATH} weka.filters.supervised.instance.StratifiedRemoveFolds -N 10 -F #{i} -S #{seed} -c last -i #{train6cd}Rn.arff -o #{train6cd}Test#{i-1}.arff")
  system("java -classpath #{CPATH} weka.filters.supervised.instance.StratifiedRemoveFolds -N 10 -F #{i} -V -S #{seed} -c last -i #{train6cd}Rn.arff -o #{train6cd}Train#{i-1}.arff")
}
end
as=Array.new
b=Array.new
k=0
com=-2
stri="abb"
confidence=[0.1]#,0.2,0.25,0.3,0.4,0.5]#,0.6,0.7,0.8,0.9]
numobj=[2]#,3,4,5,6,7,8,9,10,11]
confidence.each {|param1|
numobj.each{|param2|
  stratXval(ARGV[0],ARGV[1])
  0.upto(ARGV[1].to_i-1) {|j|
    #system("java -classpath #{CPATH} weka.classifiers.trees.J48 -t #{ARGV[0]}Train#{j}.arff -T #{ARGV[0]}Test#{j}.arff -C #{param1} -M#{param2} > J48#{param2}Fold#{j}.out")
	 system("java -classpath #{CPATH} weka.classifiers.trees.J48 -t #{ARGV[0]}Train#{j}.arff -T #{ARGV[0]}Test#{j}.arff  -C #{param1} -M #{param2} > J48#{param1}Fold#{j}.out")
str=File.open("J48#{param1}Fold#{j}.out")
p=str.grep(/Kappa statistic/)
#puts p
#puts "#{p[1]}"
poo=p[1]   
md=/(\w+)(\s*)(((|-)(\d)(\.)(\d+))|0)/.match(poo)
#puts "#{md}"
as[j]="#{md[3]}"
	
  }
as.collect! {|i| i.to_f} 
#puts as.inject(:+)
bs=as.inject(:+)
b[k]= bs/10
#ka=bs/10
if b[k] > com 
com=b[k]
stri="kappa is #{com} with confidence: #{param1} and MinNumObj: #{param2}"
#puts stri
end
k+=1
#puts "kappa is #{ka} with confidence: #{param1} and MinNumObj: #{param2}"
}

}
#c=b.sort!
#puts c[last]
puts com
puts stri

