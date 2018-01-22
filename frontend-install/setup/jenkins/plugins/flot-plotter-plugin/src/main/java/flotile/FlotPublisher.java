// Copyright (c) 2014 Cogent Embedded, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package flotile;

import java.io.*;
import java.util.*;
import hudson.*;
import hudson.tasks.*;
import hudson.model.*;
import org.kohsuke.stapler.DataBoundConstructor;
import org.kohsuke.stapler.QueryParameter;
import org.kohsuke.stapler.StaplerRequest;
import org.kohsuke.stapler.StaplerResponse;
import java.io.IOException;

@SuppressWarnings("unchecked")
public class FlotPublisher extends Recorder {
	
	@DataBoundConstructor
	public FlotPublisher() {
		
	}
	
	public BuildStepMonitor getRequiredMonitorService() {
		return BuildStepMonitor.NONE;
	}
	
	@Override
    public Action getProjectAction(AbstractProject<?,?> project) {
        return new ChartAction(project);
    }
	
  @Override
		public boolean perform(AbstractBuild<?,?> build, Launcher launcher, BuildListener listener) throws InterruptedException, IOException {
	 			return true;	
		}

	@Extension
    public static final DescriptorImpl DESCRIPTOR = new DescriptorImpl();
    public static final class DescriptorImpl extends BuildStepDescriptor<Publisher> {
    	
    	public DescriptorImpl() {
    		super(FlotPublisher.class);
    		load();
    	}

    	@Override
    	public boolean isApplicable(Class<? extends AbstractProject> jobType) {
    		return true; // applicable to all project type
    	}

    	@Override
    	public String getDisplayName() {
    		return "Flot Publisher";
    	}
  	
    }
}
