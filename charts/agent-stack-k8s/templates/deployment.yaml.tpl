apiVersion: {{ include "common.capabilities.deployment.apiVersion" . }}
kind: Deployment
metadata:
  name: {{ template "common.names.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "common.labels.standard" . | nindent 4 }}
    {{- if .Values.extraLabels }}
    {{- toYaml .Values.extraLabels | nindent 4 }}
    {{- end }}
    {{- if .Values.extraAnnotations }}
spec:
  selector:
    matchLabels: {{- include "common.labels.matchLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
      {{- include "common.labels.standard" . | nindent 8 }}
      {{- if .Values.api.extraLabels }}
      {{- toYaml .Values.api.extraLabels | nindent 8 }}
      {{- end }}
      annotations:
      {{- if .Values.api.extraAnnotations }}
        {{- toYaml .Values.api.extraAnnotations | nindent 8 }}
      {{- end }}
        checksum/config: {{ include (print $.Template.BasePath "/config.yaml.tpl") . | sha256sum }}
        checksum/secrets: {{ include (print $.Template.BasePath "/secrets.yaml.tpl") . | sha256sum }}
    {{- end }}  
    spec:
      serviceAccountName: {{ template "common.names.fullname" . }}
      nodeSelector:
{{ toYaml $.Values.nodeSelector | indent 8 }}
      containers:
      - name: controller
        terminationMessagePolicy: FallbackToLogsOnError
        image: {{ .Values.image }}
        env:
        - name: CONFIG
          value: /etc/config.yaml
        envFrom:
          - secretRef:
              name: {{ template "common.names.fullname" . }}-secrets
        volumeMounts:
          - name: config
            mountPath: /etc/config.yaml
            subPath: config.yaml
        resources:
          requests:
            cpu: 100m
            memory: 100Mi

        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
          seccompProfile:
            type: RuntimeDefault
      volumes:
        - name: config
          configMap:
            name: {{ template "common.names.fullname" . }}-config

