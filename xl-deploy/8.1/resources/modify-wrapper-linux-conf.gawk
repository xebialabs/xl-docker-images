#!/usr/bin/gawk -f

# Add the node-conf directory to the start of the classpath
/^wrapper.java.classpath.1=/ {
  print "wrapper.java.classpath.1=node-conf";
}

# Move the other classpath entries up by one
match($0, /^(wrapper.java.classpath).([0-9]+)=(.*)$/, a) {
  printf("%s.%d=%s\n", a[1], (a[2]+1), a[3]);
  next;
}

# Count the number of additional JVM arguments
/^wrapper.java.additional.*/ {
  additionals = additionals + 1
}

# Remove hard coded JVM memory limits
/^(wrapper.java.additional).([0-9]+)=-Xm[sx].*$/ {
  additionals = additionals - 1
  next;
}

# Renumber the additional JVM arguments
match($0, /^(wrapper.java.additional).([0-9]+)=(.*)$/, a) {
  printf("%s.%d=%s\n", a[1], additionals, a[3]);
  next;
}

# If none of the previous lines matched, just print the line
{ print $0 }

# Add dynamic JVM memory limits based on Docker container limits
END {
  printf("wrapper.java.additional.%d=-XX:+UnlockExperimentalVMOptions\n", additionals + 1);
  printf("wrapper.java.additional.%d=-XX:+UseCGroupMemoryLimitForHeap\n", additionals + 2);
}
