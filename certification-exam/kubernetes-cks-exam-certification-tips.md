# Certified Kubernetes Security Specialist (CKS) Exam Preparation Tips

- [Certified Kubernetes Security Specialist (CKS) Exam Preparation Tips](#certified-kubernetes-security-specialist-cks-exam-preparation-tips)
  - [Course Taken](#course-taken)
  - [Vi / Vim Setting for yaml to Edit Comfortably & Efficiently](#vi--vim-setting-for-yaml-to-edit-comfortably--efficiently)
  - [Command Alias](#command-alias)
  - [Tmux Setting](#tmux-setting)
  - [Bookmark Allowed Website: Important Content / Exam Objective Example (Mainly kubernetes.io)](#bookmark-allowed-website-important-content--exam-objective-example-mainly-kubernetesio)
  - [Lab Practice](#lab-practice)
  - [During Exam](#during-exam)
- [References](#references)
- [Appendix](#appendix)
  - [Bookmark Link for the Study](#bookmark-link-for-the-study)
  - [Frequenly Use vi/vim commands](#frequenly-use-vivim-commands)

Recently, I have completed Certified Kubernetes Security Specialist ([CKS](https://www.cncf.io/certification/cks/)) certification of [The Linux Foundation](https://www.linuxfoundation.org). Here are a few tips for the exam which might help you as well to crack the same exam.


## Course Taken
I have taken the following three courses before giving the exam. In these courses, I got practice material, hands-on lab and exam simulation environment which helped me to clear the CKS exam.
- [Kubernetes Security Essentials (LFS260) by THE LINUX FOUNDATION](https://training.linuxfoundation.org/training/kubernetes-security-essentials-lfs260/)
- [Kubernetes CKS 2021 Complete Course - Theory - Practice by Kim Wüstkamp, Killer Shell](https://www.udemy.com/share/103Mds2@FG1jV2JjSVEHdEBGC3JNfT1HYA==/)
- [Certified Kubernetes Security Specialist (CKS) by William Boyd, A CLOUD GURU](https://acloudguru.com/course/certified-kubernetes-security-specialist-cks)

## Vi / Vim Setting for yaml to Edit Comfortably & Efficiently

Added few setting in .vimrc profile which help to edit yaml file effectively and efficiently. 

```bash
cat <<EOF>~/.vimrc
set ts=2 sw=2 sts=2 et ai number
syntax on
EOF
```

Or may be follow below procedure:

```bash
echo "set ts=2 sts=2 sw=2 et number" >> ~/.vimrc
```

While copying part of yaml from kubernetes.io site, enable paste mode first using `:set paste` which will keep source formatting. 

Disable paste mode by using command: `:set nopaste` in vim command mode. Again turn on auto intendation mode using `:set ai`.

To indent multiple line, go to appropriate line and press `:shift+v` and select required line using `up/down` arrow keys. Then to indent the marked lines press  `>`or `<` and to repeat same action use `.`.



## Command Alias

In CKS exam environment, by default `kubectl` with `k` alias and bash autocompletion is configured. 

Used below command alias to type command quickly and check various resources in a single command for a namespace. 

```bash
cat <<EOF>kalias.sh
alias kgn="k get node" 
alias aa='k get all,sa,ep,sc,pv,pvc,cm,netpol'
alias kn='k config set-context --current --namespace '
alias kcc='k config get-contexts'

# help to add parameter quickly with kubectl or k 
export do="--dry-run=client -o yaml" o="-o wide" y="-o yaml" l="--show-labels" 
EOF

source kalias.sh
```



## Tmux Setting

Tmux is a great tool but I havn't used because copy and paste method is different than the normal termal. Also time is ticking and need to move quickly to answer all the questions.....



## Bookmark Allowed Website: Important Content / Exam Objective Example ([Mainly kubernetes.io](kubernetes.io))

In my bookmark manager, I added necessary sample yaml and exam objective topics from [kubernetes](kubernetes.io) and external allowed sites so that I could check content quickly when it is required to solve the exam question. 



## Lab Practice

At the end, do a lot of practice in your lab which will help to think and make an action plan for the question in the exam. To answer all the questions you have to act quickly and the allowed time is only 120 min which runs fast.

- Use imperative command to create skeleton for pod or deployment and then modify/add extra parameters
- Use imperative command to expose service
- Use bash search command `ctl+r`to run previously executed command.

## During Exam
During the exam, first try to solve the question which has more weight compared to the lower weight question.

In this way, most likely, you will be able to avoid troubleshooting activity for the lower weight question if not solved in the first attempt or easily within your timeline. Because of exam pressure, sometimes you may give more time to lower weight questions, As a consequence, at the end you may not be able to give sufficient time to higher weight questions.



# References
- https://www.cncf.io/certification/cks/
- https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks
- [Kubernetes Security Essentials (LFS260) by THE LINUX FOUNDATION](https://training.linuxfoundation.org/training/kubernetes-security-essentials-lfs260/)
- [Kubernetes CKS 2021 Complete Course - Theory - Practice by Kim Wüstkamp, Killer Shell](https://www.udemy.com/share/103Mds2@FG1jV2JjSVEHdEBGC3JNfT1HYA==/)
- [Certified Kubernetes Security Specialist (CKS) by William Boyd, A CLOUD GURU](https://acloudguru.com/course/certified-kubernetes-security-specialist-cks)
- [CKS CKA and CKAD Simulator](https://killer.sh/)



# Appendix

## Bookmark Link for the Study
- https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/
- https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/
- https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook
- https://kubernetes.io/docs/reference/access-authn-authz/webhook/
- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/#options
- https://github.com/kubernetes/dashboard/blob/master/docs/common/dashboard-arguments.md
- https://kubernetes.io/docs/concepts/services-networking/ingress/
- https://kubernetes.io/docs/concepts/services-networking/network-policies/#networkpolicy-resource
- https://kubernetes.io/docs/concepts/security/controlling-access/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/
- https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
- https://kubernetes.io/docs/concepts/policy/pod-security-policy/
- https://kubernetes.io/docs/concepts/security/pod-security-standards/
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#securitycontext-v1-core
- https://kubernetes.io/docs/concepts/containers/runtime-class/
- https://kubernetes.io/docs/tutorials/clusters/apparmor/
- https://kubernetes.io/docs/tutorials/clusters/seccomp/#create-a-pod-with-a-seccomp-profile-for-syscall-auditing
- https://kubernetes.io/docs/tasks/debug-application-cluster/audit/
- https://kubernetes.io/blog/2018/07/18/11-ways-not-to-get-hacked/
- https://aquasecurity.github.io/trivy/v0.18.3/
- https://github.com/aquasecurity/kube-bench
- https://gitlab.com/apparmor/apparmor/-/wikis/Documentation
- https://falco.org/docs/
- https://docs.sysdig.com/?lang=en
- https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/
- https://kubernetes.io/blog/2021/04/06/podsecuritypolicy-deprecation-past-present-and-future/
- https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

## Frequenly Use vi/vim commands

```bash
w ==> jump by start of words
4w >> jump muultiple word
e ==> jump by end of words
3e>> multiple at a time
b ==> jump backward by words
0 ==> (zero) is to jump to the start of the line
$ ==> (dollar) jumps to end of line
gg ==> to go to top of page
G ==> to go to bottom of page
dd ==> delete current line
y ==> yank/copy current line
P ==> paste content before cursor
p ==> paster content after cursor
i ==> enter insert mode to input text in current cursor location
a ==> enter insert mode and move cursor to append to the existing line
u ==> undo last action
. ==> (dot) to repeat last command
Ctrl + r ==> redo last action
v ==> to visually select multiple lines


:5 ==> go to 5th line in the file
:N ==> go to Nth line in the file
/search_text ==> search for search_text
n ==> repeat search in same direction
:%s/old_text/new_text/g ==> replace all old_text with new_text throughput file
:%s/old_text/new_text/gc ==> replace all old_text with new_text throughput file asking for confirmation before making each change
:set et ==> set expandtabs to spaces
:set number ==> show line numbers
:set sw=2 ==> shiftwidth of tab from default 8 to 2 spaces
:set ts=2 ==> set tabstop to 2 spaces
:set sts ==> set softtabstop to 2 spaces
```

