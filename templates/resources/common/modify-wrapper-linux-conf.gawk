#!/usr/bin/gawk -f

# Add the node-conf directory to the start of the classpath
/^wrapper.java.classpath.1=/ {
  print "wrapper.java.classpath.1=node-conf";
}

# Move the other classpath entries up by one
match($0, /^(wrapper.java.classpath).([0-9]+)=(.*)$/, a) {
  printf("%s.%d=%s\n", a[1], (a[2]+1), a[3]);
  # Keep track of the last classpath number
  last_classpath_number = a[2] + 1
  next;
}

# Add the new classpath entries right after the last classpath entry
{
  if (!added_new_classpath && last_classpath_number) {
    printf("wrapper.java.classpath.%d=driver/jdbc/*\n", last_classpath_number + 1);
    printf("wrapper.java.classpath.%d=driver/mq/*\n", last_classpath_number + 2);
    added_new_classpath = 1  # Ensure this block only runs once
  }
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
  printf("wrapper.java.additional.%d=-XX:+UseContainerSupport\n", additionals + 1);
  printf("wrapper.java.additional.%d=-XX:MaxRAMPercentage=50\n", additionals + 2);
}

# Enable JMX exporter for Prometheus
END {
  printf("wrapper.java.additional.%d=-Dcom.sun.management.jmxremote\n", additionals + 3);
  printf("wrapper.java.additional.%d=-Dcom.sun.management.jmxremote.authenticate=false\n", additionals + 4);
  printf("wrapper.java.additional.%d=-Dcom.sun.management.jmxremote.ssl=false\n", additionals + 5);
  printf("wrapper.java.additional.%d=-Dcom.sun.management.jmxremote.port=9011\n", additionals + 6);
  printf("wrapper.java.additional.%d=-Dcom.sun.management.jmxremote.rmi.port=9011\n", additionals + 7);
  printf("wrapper.java.additional.%d=-javaagent:lib/jmx_prometheus_javaagent.jar=9100:conf/jmx-exporter.yaml\n", additionals + 8);
}
