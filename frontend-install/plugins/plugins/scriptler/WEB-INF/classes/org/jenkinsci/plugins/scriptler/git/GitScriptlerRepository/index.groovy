import hudson.model.Hudson;
import jenkins.model.Jenkins;

import org.jenkinsci.plugins.scriptler.git.GitScriptlerRepository;

def l=namespace(lib.LayoutTagLib)

l.layout {
    l.main_panel {
        
        h1 {
            img (src: "${app.rootUrl}plugin/scriptler/images/Git-Icon-1788C.png", width: "48", height: "48"){}
            raw " Accessing Scriptler scripts"
        }

        p {
            raw _("blurb",app.rootUrl)
        }
        pre {
            def url = "${app.rootUrl}scriptler.git"
            raw "git clone <a href='${url}'>${url}</a>"

            if (my.sshd.actualPort>0) {
                raw "\ngit clone ssh://${new URL(app.rootUrl).host}:${my.sshd.actualPort}/scriptler.git"
            }
        }
        
        if(app.hasPermission(hudson.model.Hudson.ADMINISTER)){
            p {
                raw _("reset")
                br {
                    button (type: "button", onclick: "document.location.href=${app.rootUrl}scriptler/hardResetGit"){
                       raw "hard reset"
                    }
                }
            } 
        }
        
//        h1 "Log"
//        
//        my.log.each { log -> 
//            pre {
//                b {
//                    raw "commit ${log.name}" 
//                } 
//                br {raw "Author: ${log.author}"}
//                br {raw "Commiter: ${log.commiter}"}
//                br {raw "Date: ${log.committime}"}
//                p {
//                    raw "${log.msg}"
//                }
//            }
//        }
    }
}
