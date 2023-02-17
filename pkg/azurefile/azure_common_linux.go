//go:build linux
// +build linux

/*
Copyright 2020 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package azurefile

import (
	"fmt"
	"os/exec"
	"strings"
	"time"

	"k8s.io/klog/v2"
	mount "k8s.io/mount-utils"
)

func SMBMount(m *mount.SafeFormatAndMount, source, target, fsType string, options, sensitiveMountOptions []string) error {
	return m.MountSensitive(source, target, fsType, options, sensitiveMountOptions)
}

func CleanupMountPoint(m *mount.SafeFormatAndMount, target string, extensiveMountCheck bool) error {
	var err error
	extensiveMountPointCheck := true
	forceUnmounter, ok := m.Interface.(mount.MounterForceUnmounter)
	if ok {
		klog.V(2).Infof("force unmount on %s", target)
		err = mount.CleanupMountWithForce(target, forceUnmounter, extensiveMountPointCheck, 30*time.Second)
	} else {
		err = mount.CleanupMountPoint(target, m.Interface, extensiveMountPointCheck)
	}

	if err != nil && strings.Contains(err.Error(), "target is busy") {
		klog.Warningf("unmount on %s failed with %v, try lazy unmount", target, err)
		err = forceUmount(target)
	}
	return err
}

func preparePublishPath(path string, m *mount.SafeFormatAndMount) error {
	return nil
}

func prepareStagePath(path string, m *mount.SafeFormatAndMount) error {
	return nil
}

func forceUmount(path string) error {
	cmd := exec.Command("umount", "-lf", path)
	out, cmderr := cmd.CombinedOutput()
	if cmderr != nil {
		return fmt.Errorf("lazy unmount on %s failed with %v, output: %s", path, cmderr, string(out))
	}
	return nil
}
